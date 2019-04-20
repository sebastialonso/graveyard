defmodule Graveyard.ORM.ValidationTest do
  use ExUnit.Case

  alias Graveyard.Utils.TirexsUris
  import Graveyard.Support.Fixtures.Validation

  setup do
    Application.put_env(:tirexs, :uri, "http://localhost:9200")
    Application.put_env(:graveyard, :index, "graveyard_test")
    Application.put_env(:graveyard, :type, "graveyard_test")
    Application.put_env(:graveyard, :mappings_module, nil)
    Application.put_env(:graveyard, :validate_before_insert, true)
    Application.put_env(:graveyard, :mappings, simple_mappings())
    Application.put_env(:vex, :sources, [
      [text: Graveyard.Validators.Text],
      [integer: Graveyard.Validators.Integer],
      [number: Graveyard.Validators.Number],
      [category: Graveyard.Validators.Category],
      [date: Graveyard.Validators.Date],
      [datetime: Graveyard.Validators.Datetime],
      Vex.Validators
    ])
    
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()
    # [episodes: Fixtures.episodes()]
    :ok
  end

  test "validates a mapping compliant object" do
    params = %{
      name: "Sebastian",
      age: 27,
      favourite_number: 2.71
    }
    processed = Graveyard.ORM.Validation.validate(params)
    assert Map.has_key?(processed, :__valid__)
    assert Map.has_key?(processed, :__errors__)
    assert processed.__valid__
    refute processed.__errors__
  end

  test "does not validates an invalid mapping object" do
    # Values of `name` and `age` are invalid, value of `sex` not in permitted values
    params = %{
      name: 3,
      age: "not a number",
      favourite_number: 2.71
    }
    processed = Graveyard.ORM.Validation.validate(params)

    assert Map.has_key?(processed, :__valid__)
    assert Map.has_key?(processed, :__errors__)
    refute processed.__valid__
    assert processed.__errors__
    assert Map.keys(processed.__errors__) == [:age, :name]
  end

  test "returns nil errors for mapping compliant object" do
    params = %{
      name: "Sebastian",
      age: 27,
      favourite_number: 2.71
    }
    assert Graveyard.ORM.Validation.group_errors(params) == nil
  end

  test "returns errors for non-compliant object" do
    params = %{
      name: 13,
      age: 10,
      favourite_number: 2.71
    }
    assert Graveyard.ORM.Validation.group_errors(params)
    assert Map.keys(Graveyard.ORM.Validation.group_errors(params)) == [:age, :name]
  end
end