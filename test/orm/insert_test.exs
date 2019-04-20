defmodule Graveyard.ORM.InsertTest do
  use ExUnit.Case

  alias Graveyard.Record
  alias Graveyard.Support
  alias Graveyard.Utils.TirexsUris
  alias Graveyard.Support.Fixtures
  alias Graveyard.Support.Fixtures.Validation, as: ValidationFixtures

  setup do
    Application.put_env(:tirexs, :uri, "http://localhost:9200")
    Application.put_env(:graveyard, :index, "graveyard_test")
    Application.put_env(:graveyard, :type, "graveyard_test")
    :ok
  end

  describe "insert/2" do
    setup do
      Application.put_env(:graveyard, :mappings_module, nil)
      Application.put_env(:graveyard, :mappings, Fixtures.with_oblists_mappings())
      Application.put_env(:graveyard, :validate_before_insert, false)
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

  describe "insert/2 with validation" do
    setup do
      Application.put_env(:graveyard, :mappings, ValidationFixtures.simple_mappings())
      Application.put_env(:graveyard, :validate_before_insert, true)
      TirexsUris.delete_mapping()
      Graveyard.Mappings.create_settings_and_mappings()
      :ok
    end

    test "inserts a record when validation active and valid params" do
      Application.put_env(:graveyard, :mappings, ValidationFixtures.simple_mappings())
      Application.put_env(:graveyard, :validate_before_insert, true)
      TirexsUris.delete_mapping()
      Graveyard.Mappings.create_settings_and_mappings()
  
      params = %{
        "name" => "Sebastian",
        "age" => 27,
        "favourite_number" => 3.0
      }
  
      old_count = Record.count()
      Record.insert(params)
      assert old_count < Record.count()
    end

    test "fails to insert a record when validation active and invalid params" do    
      params = %{
        "name" => "Sebastian",
        "age" => 19,
        "favourite_number" => 7
      }
  
      old_count = Record.count()
      Record.insert(params)
      assert old_count == Record.count()
    end
  
    test "return :error tuple when insertion fails due to validation" do
      params = %{
        "name" => "Sebastian",
        "age" => 19,
        "favourite_number" => 7
      }
  
      assert {:error, :validation_failure, errors} = Record.insert(params)
      assert Map.keys(errors) == [:age, :favourite_number]
    end
  end
end