defmodule Graveyard.ORM.UpdateTest do
  use ExUnit.Case

  alias Graveyard.Record
  alias Graveyard.Utils.TirexsUris

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

  setup_all do
    Application.put_env(:tirexs, :uri, "http://localhost:9200")
    Application.put_env(:graveyard, :index, "graveyard_test")
    Application.put_env(:graveyard, :type, "graveyard_test")
    Application.put_env(:graveyard, :mappings_module, CustomMappings)
    :ok
  end

  setup do
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()
    params = %{
      "title" => "Henry",
      "content" => "It's the Bilderberg group!"
    }
    {:ok, record} = Record.insert(params)

    [record: record]
  end

  describe "update/2" do
    test "updates a record", %{record: record} do
      params_to_update = %{
        "content" => "Updated"
      }
      updated = Record.update(record.id, params_to_update)
      assert updated
      {:ok, updated} = updated
      assert updated.content != record.content
    end

    test "returns nil if record is not found", %{record: _} do
      updated = Record.update(999, %{})
      refute updated
    end
  end
end