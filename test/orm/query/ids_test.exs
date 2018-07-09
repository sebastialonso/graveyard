defmodule Graveyard.ORM.Query.IdsTest do
  use ExUnit.Case

  import Graveyard.ORM.Query.Ids
  alias Graveyard.Support

  describe "ids_query/1" do
    test "returns valid query" do
      filter = %{"type" => "ids", "values" => ["asd", "qwer"]}
      expected = %{ids: %{type: Support.type(), values: ["asd", "qwer"]}}
      assert ids_query(filter) == expected
    end
  end
end