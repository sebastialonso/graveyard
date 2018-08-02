defmodule Graveyard.ORM.GroupTest do
  use ExUnit.Case

  # alias Graveyard.ORM.Group
  alias Graveyard.Errors
  alias Graveyard.Record
  alias Graveyard.Utils.TirexsUris

  alias Graveyard.Support.Fixtures

  describe "group/3" do
    setup do
      Application.put_env(:tirexs, :uri, "http://localhost:9200")
      Application.put_env(:graveyard, :index, "graveyard_test")
      Application.put_env(:graveyard, :type, "graveyard_test")
      Application.put_env(:graveyard, :mappings_module, nil)
      Application.put_env(:graveyard, :mappings, Fixtures.with_oblists_mappings())
      
      TirexsUris.delete_mapping()
      Graveyard.Mappings.create_settings_and_mappings()

      Fixtures.create_episodes()
      :ok
    end

    test "raises when :aggs argument is not a list" do
      assert_raise Errors.BadArgumentError, fn -> Record.group([], "sdsf", %{}) end
      assert_raise Errors.BadArgumentError, fn -> Record.group([], 1, %{}) end
      assert_raise Errors.BadArgumentError, fn -> Record.group([], %{}, %{}) end
      assert_raise Errors.BadArgumentError, fn -> Record.group([], nil, %{}) end
    end

    test "returns an array of objects with :data and :source keys for simple grouping" do
      actual = Record.group([], [%{"type" => "simple", "key" => "topic.name"}])
      assert Enum.count(actual) > 0
      assert Enum.all?(actual, fn(elem) -> 
        Map.has_key?(elem, :source) and Map.has_key?(elem, :data)
        Enum.all?(elem.source, fn(source) -> source.field_name == "topic.name" end)
      end)
    end

    test "returns an array of objects with :data and :source keys for range grouping" do
      actual = Record.group([], [%{"type" => "range", "key" => "topic.followers", "opts" => %{"min" => 200, "step" => 100, "max" => 800}}])
      assert Enum.count(actual) > 0
      assert Enum.all?(actual, fn(elem) -> 
        Map.has_key?(elem, :source) and Map.has_key?(elem, :data)
        Enum.all?(elem.source, fn(source) -> source.field_name == "topic.followers" end)
      end)
    end

    test "returns an array of objects with :data and :source keys for nested grouping" do
      actual = Record.group([], [%{"type" => "nested", "key" => "name", "opts" => %{"path" => "tags"}}])
      assert Enum.count(actual) > 0
      assert Enum.all?(actual, fn(elem) -> 
        Map.has_key?(elem, :source) and Map.has_key?(elem, :data)
        Enum.all?(elem.source, fn(source) -> source.field_name == "name" end)
      end)
    end
    
    test "returns an array of objects with :data and :source keys for mix" do
      actual = Record.group([], [%{"type" => "simple", "key" => "topic.name"}, %{"type" => "range", "key" => "topic.followers", "opts" => %{"min" => 200, "step" => 100, "max" => 800}}])
      assert Enum.count(actual) > 0
      assert Enum.all?(actual, fn(elem) -> 
        Map.has_key?(elem, :source) and Map.has_key?(elem, :data)
        Enum.any?(elem.source, fn(source) -> source.field_name == "topic.name" end)
        Enum.any?(elem.source, fn(source) -> source.field_name == "topic.followers" end)
      end)
    end
  end
end