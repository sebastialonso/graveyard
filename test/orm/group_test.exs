defmodule Graveyard.ORM.GroupTest do
  use ExUnit.Case

  # alias Graveyard.ORM.Group
  alias Graveyard.Errors
  alias Graveyard.Record
  alias Graveyard.Utils.TirexsUris

  alias Graveyard.Support.Fixtures

  describe "group/3" do
    @mappings Fixtures.mappings()
    setup do
      Application.put_env(:tirexs, :uri, "http://localhost:9200")
      Application.put_env(:graveyard, :index, "graveyard_test")
      Application.put_env(:graveyard, :type, "graveyard_test")
      Application.put_env(:graveyard, :mappings_module, nil)
      Application.put_env(:graveyard, :mappings, @mappings)
      
      TirexsUris.delete_mapping()
      Graveyard.Mappings.create_settings_and_mappings()

      Enum.map(Fixtures.episodes(), fn(episode) -> Record.insert(episode) end)
      :ok
    end

    test "raises when :aggs argument is not a list" do
      assert_raise Errors.BadArgument, fn -> Record.group([], "sdsf", %{}) end
      assert_raise Errors.BadArgument, fn -> Record.group([], 1, %{}) end
      assert_raise Errors.BadArgument, fn -> Record.group([], %{}, %{}) end
      assert_raise Errors.BadArgument, fn -> Record.group([], nil, %{}) end
    end

    test "returns an array of objects with :data and :source keys" do
      actual = Record.group([], [%{"type" => "simple", "key" => "topic.name"}])
      assert Enum.all?(actual, fn(elem) -> 
        Map.has_key?(elem, :source) and Map.has_key?(elem, :data)
      end)

      actual = Record.group([], [%{"type" => "range", "key" => "topic.followers", "opts" => %{"min" => 200, "step" => 100, "max" => 800}}])
      assert Enum.all?(actual, fn(elem) -> 
        Map.has_key?(elem, :source) and Map.has_key?(elem, :data)
      end)

      actual = Record.group([], [%{"type" => "simple", "key" => "topic.name"}, %{"type" => "range", "key" => "topic.followers", "opts" => %{"min" => 200, "step" => 100, "max" => 800}}])
      assert Enum.all?(actual, fn(elem) -> 
        Map.has_key?(elem, :source) and Map.has_key?(elem, :data)
      end)

    end
  end
end