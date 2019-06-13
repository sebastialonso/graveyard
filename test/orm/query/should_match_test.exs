defmodule Graveyard.ORM.Query.ShouldMatchTest do
  use ExUnit.Case

  import Graveyard.ORM.Query.ShouldMatch

  describe  "should_match/1" do
    test "returns valid query" do
      filter = %{"type" => "should_match", "field" => "state", "values" => ["element_1", "element_2"]}
      expected = [%{match: %{state: %{operator: "and", query: "element_1"}}}, %{match: %{state: %{operator: "and", query: "element_2"}}}]
      assert should_match_query(filter) == expected
    end
  end
end