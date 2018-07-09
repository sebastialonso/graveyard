defmodule Graveyard.ORM.Query.ExistsTest do
  use ExUnit.Case

  import Graveyard.ORM.Query.Exists

  describe "exists_query/1" do
    test "returns valid query" do
      filter = %{"type" => "exists", "field" => "name"}
      expected = %{exists: %{field: "name"}}
      assert exists_query(filter) == expected
    end
  end
end