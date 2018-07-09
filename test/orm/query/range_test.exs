defmodule Graveyard.ORM.Query.RangeTest do
  use ExUnit.Case

  import Graveyard.ORM.Query.Range

  describe "range_query/1" do
    test "returns valid query" do
      filter = %{"type" => "range", "field" => "created_at", "from" => "01/01/2015", "to" => "01/01/2017"}
      expected = %{range: %{created_at: %{from: "01/01/2015", to: "01/01/2017"}}}
      assert range_query(filter) == expected
    end
  end
end