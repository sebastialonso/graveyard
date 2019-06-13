defmodule Graveyard.ORM.Query.ShouldMatch do
  import Graveyard.Utils
  @doc """
  Returns a Tirexs-ready map structure for a match query (reference: https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-match-query.html)
  The format of filter must follow this example:
  ~~~
  %{"type" => "should_match", "field" => "name", "values" => ["Jav", "Mary"] "}
  ~~~
  """
  def should_match_query filter do
    filter["values"] |> Enum.map(fn(constraint_value) -> 
      %{match: Map.new([{to_indifferent_atom(filter["field"]), %{query: constraint_value, operator: "and"}}])}
    end)
  end
end
