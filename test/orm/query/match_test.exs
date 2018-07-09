defmodule Graveyard.ORM.Query.MatchTest do
  use ExUnit.Case

  import Graveyard.ORM.Query.Match

  describe "match_query/1" do
    test "returns valid query" do
      filter = %{"type" => "match", "field" => "color", "value" => "red"}
      expected = %{match: %{color: %{operator: "and", query: "red"}}}
      assert match_query(filter) == expected
    end
  end
end