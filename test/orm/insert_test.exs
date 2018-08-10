defmodule Graveyard.ORM.InsertTest do
  use ExUnit.Case

  alias Graveyard.Record
  alias Graveyard.Support
  alias Graveyard.Utils.TirexsUris
  alias Graveyard.Support.Fixtures

  defmodule CustomMappings do
    import Tirexs.Mapping

    def get_mappings(index_name, type_name) do
      index = [index: index_name, type: type_name]
      mappings do
        indexes "title", type: "text"
        indexes "content", type: "text", analyzer: "nGram_analyzer"
      end
    end
  end

  setup do
    Application.put_env(:tirexs, :uri, "http://localhost:9200")
    Application.put_env(:graveyard, :index, "graveyard_test")
    Application.put_env(:graveyard, :type, "graveyard_test")
    Application.put_env(:graveyard, :mappings_module, nil)
    Application.put_env(:graveyard, :mappings, Fixtures.with_oblists_mappings())
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()
    [episodes: Fixtures.episodes()]
  end

  test "inserts a record", %{episodes: episodes} do
    old_count = Record.count()
    Record.insert(episodes |> List.first)
    assert old_count < Record.count()
  end

  test "records has created_at and updated_at", %{episodes: episodes} do
    assert {:ok, %{created_at: _, updated_at: _}} = Record.insert(episodes |> List.first)
  end

  test "for oblists, the __aux field is populated", %{episodes: episodes} do
    {:ok, record} = Record.insert(episodes |> List.first, %{maquilate: false})
    aux = Map.get(record, :_source) |> Map.get(:__aux)
    assert Enum.count(aux) > 0
  end

  test "returns a list of ids", %{episodes: episodes} do
    actual = Record.insert(episodes)
    assert is_list(actual)
    assert Enum.count(actual) > 0
  end
end