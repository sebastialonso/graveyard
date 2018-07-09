defmodule Graveyard.ORM.Query.Range do
  import Graveyard.Utils
  @doc """
  Returns a Tirexs-ready map structure for a range query (reference: https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-range-query.html)
  The format of filter must follow this example:
  ~~~
  %{"type" => "range", "field" => "released_at", "from" => "01/01/2014", "to" => "01/02/2014"}
  ~~~
  """
  def range_query filter do
    settings = %{}
    settings = unless is_nil(filter["from"]) do
      Map.put(settings, :from, filter["from"])
    else
      settings
    end
    settings = unless is_nil(filter["to"]) do
      Map.put(settings, :to, filter["to"])
    else
      settings
    end
    %{
      range: Map.new([{to_indifferent_atom(filter["field"]), settings}]) 
    }
  end
end
