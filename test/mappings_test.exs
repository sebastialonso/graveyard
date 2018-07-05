defmodule Graveyard.MappingsTest do
  use ExUnit.Case

  alias Graveyard.Mappings
  alias Graveyard.Support

  defmodule CustomMappings do
    import Tirexs.Mapping

    def get_mappings(index_name, type_name) do
      index = [index: index_name, type: type_name]
      mappings do
        indexes "name", type: "text"
        indexes "description", type: "text", analyzer: "nGram_analyzer"
      end
    end
  end

  setup do
    Tirexs.HTTP.delete(Support.index())
    :ok
  end

  describe "get_mappings/2" do
    test "returns a valid mappings object" do
      actual = Mappings.get_mappings()
      assert Keyword.fetch!(actual, :index)
      assert Keyword.fetch!(actual, :mapping)
      assert_raise KeyError, fn -> Keyword.fetch!(actual, :other) end
    end
  end

  describe "create_settings_and_mappings/0" do
    test "returns :ok tuple from ElasticSearch" do
      {state, code, reason} = Mappings.create_settings_and_mappings()      
      assert state == :ok
      assert reason = %{acknowledged: true}
    end
  end
end