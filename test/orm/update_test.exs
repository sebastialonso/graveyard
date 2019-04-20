defmodule Graveyard.ORM.UpdateTest do
  use ExUnit.Case

  alias Graveyard.Record
  alias Graveyard.Utils.TirexsUris
  alias Graveyard.Support.Fixtures.Validation, as: ValidationFixtures

  setup do
    Application.put_env(:tirexs, :uri, "http://localhost:9200")
    Application.put_env(:graveyard, :index, "graveyard_test")
    Application.put_env(:graveyard, :type, "graveyard_test")
    Application.put_env(:graveyard, :mappings_module, nil)
    Application.put_env(:graveyard, :mappings, ValidationFixtures.simple_mappings())
    Application.put_env(:graveyard, :validate_before_insert, false)

    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()

    params = %{
      "name" => "Henry",
      "age" => 25,
      "favourite_number" => 3.14
    }
    {:ok, record} = Record.insert(params)

    [record: record]
  end

  describe "update/2 without validation" do
    test "updates a record", %{record: record} do
      params_to_update = %{
        "name" => "Sebastian", "age" => 27
      }
      updated = Record.update(record.id, params_to_update)
      assert updated
      {:ok, updated} = updated
      assert updated.name != record.name
    end

    test "returns nil if record is not found", %{record: _} do
      updated = Record.update(999, %{})
      refute updated
    end
  end

  describe "update/2 with validation" do
    setup do
      Application.put_env(:graveyard, :validate_before_update, true)
      :ok
    end

    test "updates a record", %{record: record} do
      params_to_update = %{
        "name" => "Sebastian", "age" => 27
      }
      {:ok, object} = Record.update(record.id, params_to_update)
      assert object.name == params_to_update["name"]
      assert object.age == params_to_update["age"]
    end
    
    test "fails to update record due to validation", %{record: record} do
      params_to_update = %{
        "name" => "Sebastian", "age" => "not a number, pal"
      }
      assert {:error, :validation_failure, errors} = Record.update(record.id, params_to_update)
      assert Map.keys(errors) == [:age]
    end
  end
end