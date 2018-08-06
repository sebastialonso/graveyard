defmodule Graveyard.ORM.FindTest do
  use ExUnit.Case

  alias Graveyard.Record
  alias Graveyard.Support
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

  setup do
    Application.put_env(:tirexs, :uri, "http://localhost:9200")
    Application.put_env(:graveyard, :index, "graveyard_test")
    Application.put_env(:graveyard, :type, "graveyard_test")
    Application.put_env(:graveyard, :mappings_module, CustomMappings)
    
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()
    record = %{
      "name" => "Henry",
      "content" => "It's the Bilderberg group!"
    }
    {:ok, 201, es_object} = Tirexs.HTTP.post("#{Support.index()}/#{Support.type()}", record)

    [record: es_object]
  end

  test "finds an existing record by id", %{record: record} do
    object = Record.find(record._id)
    assert object
    assert object.id
  end

  test "returns nil when record is not found", %{record: record} do
    object = Record.find(999)
    refute object
  end
end