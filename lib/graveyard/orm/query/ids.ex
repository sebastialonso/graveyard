defmodule Graveyard.ORM.Query.Ids do
  alias Graveyard.Support
  @doc """
  Returns a Tirexs-ready map structure for an ids query (reference: https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-ids-query.html)
  The format of filter must follow this example:
  ~~~
  %{"type" => "ids", "values" => ["xxwqqw324", "xxso-c32"]}
  ~~~
  """
  def ids_query(filter) do
    %{
      ids: %{
        type: Support.type(), values: filter["values"]
      }
    } 
  end
end