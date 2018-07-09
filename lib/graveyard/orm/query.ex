defmodule Graveyard.ORM.Query do
  import Graveyard.ORM.Query.Match
  import Graveyard.ORM.Query.Range
  import Graveyard.ORM.Query.Ids#, Ids, Exists}
  import Graveyard.ORM.Query.Exists

  def build_query(filters) do
    case Enum.empty?(filters) do
      true -> %{}
      false ->
        # must_expressions = Map.merge(build_AND_expressions(filters), build_OR_expressions(filters))
        must_expressions = build_AND_expressions(filters)#Map.merge(, build_OR_expressions(filters))
        must_not_expressions = %{}#Map.merge(build_NAND_expression(filters))
        %{
          query: %{
            bool: %{
              must: must_expressions,
              must_not: must_not_expressions
            }
          }
        }
     end 
  end

  defp build_AND_expressions(filters) do
    filters
    |> get_must_from_filters
    |> Enum.reduce([], fn(constraint, acc) -> 
      acc ++ [build_must(constraint)]
    end)
  end

  defp get_must_from_filters(filters) do
    filters |> Enum.filter(fn(constraint) -> 
      Enum.member?(
        ["range", "match", "ids", "exists"], 
        Map.get(constraint, "type")
      )
    end)
  end

  defp build_must filter do
    case filter["type"] do
      "match" ->
        match_query filter
      "range" ->
        range_query filter
      "ids" ->
        ids_query filter
      "exists" ->
        exists_query filter
    end
  end
end