defmodule Graveyard.ORM.Search do
  defmacro __using__(_) do
    quote do
      alias unquote(Graveyard.Support)
      alias unquote(Graveyard.Utils.TirexsUris)
      import Graveyard.Utils
      import Graveyard.ORM.Query

      # TODO Implemen is_empty? macro for lists
      def search(filters \\ [], page \\ 1, page_size \\ 10)
      def search(filters, page, page_size) do
        IO.inspect "final query"
        IO.inspect build_paginated_query(filters, page, page_size)
        build_paginated_query(filters, page, page_size)
        |> do_search
      end

      defp build_paginated_query(filters, page, page_size) do
        from = page_size * (page - 1)
        query = build_query(filters)
        search = %{from: from, size: page_size}
        if Enum.empty?(query) do
          %{
            search: search,
            page: page,
            index: Support.index()
          }  
        else
          %{
            search: Map.merge(search, query),
            page: page,
            index: Support.index()
          }
        end
      end

      defp do_search(query) do
        case Tirexs.Query.create_resource(to_keyword_list(query)) do
          {:ok, 200, %{hits: %{hits: hits}}} ->
            %{
              records: Enum.map(hits, fn(hit) -> Graveyard.Record.find(hit._id) end),
              current_page: Map.get(query, :page),
              total_pages: count_query_pages(query)
            }
          {:error, status, %{error: %{reason: reason}}} ->
            %{
              records: [],
              current_page: 1,
              total_pages: 1
            }
        end
      end

      defp count_query_pages(query) do
        qquery = query
        |> Map.get(:search)
        
        # If query key exists, count elements that match query. Else count all of them
        count = if Map.has_key?(qquery, :query) do
          case TirexsUris.count(%{query: qquery.query}) do
            {:ok, 200, %{count: count}} -> count
            {:error, status, stuff} -> 
              IO.inspect(status)
              IO.inspect(stuff)
              0
          end
        else
          case TirexsUris.count() do
            {:ok, 200, %{count: count}} -> count
            {:error, status, stuff} -> 
              IO.inspect(status)
              IO.inspect(stuff)
              0
          end
        end
        divisor = query |> Map.get(:search) |> Map.get(:size)

        count / divisor
        |> Float.ceil
        |> round
      end
    end
  end
end

defmodule Graveyard.Utils.TirexsUris do
  import Tirexs.HTTP
  import Graveyard.Utils
  alias Graveyard.Support
  
  def count() do
    post("#{Support.index()}/#{Support.type()}/_count")
  end

  def count(query) when is_map(query) do
    post("#{Support.index()}/#{Support.type()}/_count", to_keyword_list(query))
  end

  def mappings() do
    get("#{Support.index()}/_mapping/#{Support.type()}")
  end
end