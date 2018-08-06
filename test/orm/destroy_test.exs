defmodule Graveyard.ORM.DestroyTest do
  use ExUnit.Case, async: false

  alias Graveyard.Record
  alias Graveyard.Support
  alias Graveyard.Errors
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

  describe "destroy/2" do
    setup do
      Application.put_env(:tirexs, :uri, "http://localhost:9200")
      Application.put_env(:graveyard, :index, "graveyard_test")
      Application.put_env(:graveyard, :type, "graveyard_test")
      Application.put_env(:graveyard, :mappings_module, CustomMappings)

      TirexsUris.delete_mapping()
      Graveyard.Mappings.create_settings_and_mappings()
      record = %{
        "name" => "Henry",
        "content" => "It's the godamn Men in Black!"
      }
      {:ok, 201, es_object} = Tirexs.HTTP.post("#{Support.index()}/#{Support.type()}", record)
      [record: es_object]
    end

    test "deletes a document", %{record: record} do
      object = Record.destroy(record._id)
      assert {:error, 404, _} = Tirexs.HTTP.get("#{Support.index()}/#{Support.type()}/#{record._id}")
    end

    test "returns deleted document", %{record: record} do
      deleted = Record.destroy(record._id)
      assert deleted
      assert deleted.id
      assert deleted.id == record._id
    end

    test "return nil if record is not found", %{record: record} do
      destroyed = Record.destroy(999)
      refute destroyed
    end

    test "raise error if something fishy goes on", %{record: record} do
      Application.put_env(:tirexs, :uri, "http://localhost:9201")
      assert_raise Errors.ElasticSearchInstanceError, fn() -> Record.destroy(record._id) end
    end
  end
end