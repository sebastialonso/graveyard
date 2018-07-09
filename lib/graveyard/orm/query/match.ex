defmodule Graveyard.ORM.Query.Match do
  import Graveyard.Utils
  @doc """
  Returns a Tirexs-ready map structure for a match query (reference: https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-match-query.html)
  The format of filter must follow this example:
  ~~~
  %{"type" => "match", "field" => "name", "value" => "Jav"}
  ~~~
  """
  def match_query filter do
    %{match: Map.new([{to_indifferent_atom(filter["field"]), %{query: filter["value"], operator: "and"}}])}
  end
end