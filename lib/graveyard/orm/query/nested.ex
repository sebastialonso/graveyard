defmodule Graveyard.ORM.Query.Nested do
  @doc """
    Returns a Tirexs-ready keyword list structure for a nested query (reference: https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-nested-query.html)
    The format of filter must follow this example
    ~~~
    %{"type" => "nested", "path" => "path_to-field", "queries":
      [
        %{"type" => "match", "field" => "name", "value" => "Jav"},
        %{"type" => "match", "field" => "iss", "value" => 23 }
      ]
    }
    ~~~
    For additional info on how to merge first-order queries and nested queries in a single Elastic query, see (https://stackoverflow.com/questions/15577474/combined-non-nested-and-nested-query-in-elasticsearch)
    """

  import Graveyard.ORM.Query.{Match, Range, Exists, ShouldMatch}

  def nested_query(filter) do
    queries = Enum.map(filter["queries"], fn(query) -> 
      kery = query 
        |> Map.put("field", filter["path"] <> "." <> query["field"])
      cond do
        Enum.member?(["match"], kery["type"]) ->
          kery 
          |> match_query
        Enum.member?(["should_match"], kery["type"]) ->
          kery
          |> should_match_query
        Enum.member?(["range"], kery["type"]) ->
          kery
          |> range_query
        Enum.member?(["exists"], kery["type"]) ->
          kery
          |> exists_query
      end
    end)
    [
      nested: [
        path: filter["path"],
        query: [
          bool: [
            must: queries
          ]
        ]
      ]
    ]

  end
end