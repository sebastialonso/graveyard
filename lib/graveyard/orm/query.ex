defmodule Graveyard.ORM.Query do
  import Graveyard.ORM.Query.Match
  import Graveyard.ORM.Query.ShouldMatch
  import Graveyard.ORM.Query.Range
  import Graveyard.ORM.Query.Ids
  import Graveyard.ORM.Query.Exists
  import Graveyard.ORM.Query.Nested

  def build_query(filters) do
    case Enum.empty?(filters) do
      true -> %{}
      false ->
        must_expressions = build_AND_expressions(filters) ++ build_OR_expressions(filters)
        must_not_expressions = build_NAND_expression(filters)
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

  defp build_NAND_expression(filters) do
    filters
    |> get_must_not_from_filters
    |> Enum.reduce([], fn(constraint, acc) -> 
      acc ++ [build_must_not(constraint)]
    end)
  end

  defp build_OR_expressions(filters) do
    filters
    |> get_shoulds_from_filters
    |> Enum.reduce([], fn(constraint, acc) -> 
      acc + [build_bool_should(constraint)]
    end)
  end

  defp get_must_from_filters(filters) do
    filters |> Enum.filter(fn(constraint) -> 
      Enum.member?(
        ["range", "match", "ids", "exists", "nested"], 
        Map.get(constraint, "type")
      )
    end)
  end

  defp get_must_not_from_filters(filters) do
    filters |> Enum.filter(fn(constraint) -> 
      Enum.member?(["must_not_match", "must_not_range", "missing"], Map.get(constraint, "type"))
    end)
  end

  defp get_shoulds_from_filters(filters) do
    filters |> Enum.filter(fn(constraint) -> 
      Enum.member?(["should_match"], Map.get(constraint, "type"))
    end)
  end

  defp build_bool_should filter do
    or_clauses = case filter["type"] do
      "should_match" ->
        should_match_query filter
    end

    [bool: [should: or_clauses]]
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
      "nested" ->
        nested_query filter
    end
  end

  defp build_must_not filter do
    case filter["type"] do
      "must_not_match" ->
        match_query filter
      "must_not_range" ->
        range_query filter
      "missing" ->
        exists_query filter
    end
  end
end