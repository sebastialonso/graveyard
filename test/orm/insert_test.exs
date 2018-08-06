defmodule Graveyard.ORM.InsertTest do
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
    Application.put_env(:graveyard, :mappings, nil)
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()
    :ok
  end

  test "inserts a record" do
    record = %{
      "title" => "Henry",
      "content" => "It's the Bilderberg group!"
    }
    
    assert {:ok, %{id: _}} = Record.insert(record)
  end

  test "records has created_at and updated_at" do
    record = %{
      "title" => "Henry",
      "content" => "It's the Bilderberg group!"
    }
    
    assert {:ok, %{created_at: _, updated_at: _}} = Record.insert(record)
  end
end