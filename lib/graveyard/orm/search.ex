defmodule Graveyard.ORM.Search do
  defmacro __using__(_) do
    quote do

      # TODO Implemen is_empty? macro for lists
      def search(filters \\ [], page \\ 1, page_size \\ 10, opts \\ %{})
      def search(filters, page, page_size, opts) do
        Graveyard.ORM.Search.search(filters, page, page_size, opts)
      end
    end
  end
  
  alias Graveyard.Support
  alias Graveyard.Utils.TirexsUris
  alias Graveyard.ORM.Opts
  import Graveyard.Utils
  import Graveyard.ORM.Query

  def search(filters, page, page_size, opts) do
    # Merge suplied options with default options
    opts = opts
      |> Opts.Search.options

    filters
      |> Graveyard.ORM.Search.build_paginated_query(page, page_size, opts)
      |> Graveyard.ORM.Search.do_search(opts)
  end

  def build_paginated_query(filters, page, page_size, opts) do
    from = page_size * (page - 1)
    query = build_query(filters)
    search = %{from: from, size: page_size, sort: order_by(opts.sort)}
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
        index: Support.index(),
      }
    end
  end

  def do_search(query, opts) do
    case Tirexs.Query.create_resource(to_keyword_list(query)) do
      {:ok, 200, %{hits: %{hits: hits}}} ->
        %{
          records: Enum.map(hits, fn(hit) -> Graveyard.Record.find(hit._id, opts) end),
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

  def order_by(sort) do
    Enum.map(sort, fn(map_element) -> 
      Enum.map(map_element, fn({key, val}) -> 
        %{key => %{order: val}}
      end)
    end) |> List.flatten
  end

  def count_query_pages(query) do
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
