defmodule Graveyard.ORM.Validation.CategoryTest do
  use ExUnit.Case

  alias Graveyard.Utils.TirexsUris
  import Graveyard.Support.Fixtures.Validations.Category

  defmodule Dragqueens do
    def options do
      [
        "Sasha Velour", "Bob the Drag Queen", "Naomi Smalls",
        "Sharon Needles", "Raja", "Violet Chachki", "Jinx Monsoon"
      ]
    end
  end

  defmodule NotFunctionHere do
    def definetely_not_options do
      []
    end
  end

  setup do
    Application.put_env(:tirexs, :uri, "http://localhost:9200")
    Application.put_env(:graveyard, :index, "graveyard_test")
    Application.put_env(:graveyard, :type, "graveyard_test")
    Application.put_env(:graveyard, :mappings_module, nil)
    Application.put_env(:graveyard, :validate_before_insert, true)
    Application.put_env(:vex, :sources, [
      [text: Graveyard.Validators.Text],
      [integer: Graveyard.Validators.Integer],
      [number: Graveyard.Validators.Number],
      [category: Graveyard.Validators.Category],
      [date: Graveyard.Validators.Date],
      [datetime: Graveyard.Validators.Datetime],
      Vex.Validators
    ])
    
    :ok
  end

  test "validates a mapping compliant object (basic category)" do
    Application.put_env(:graveyard, :mappings, simple_mappings())
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()

    params = %{
      favourite_drag_queen: "Raja"
    }
    assert Graveyard.ORM.Validation.validate_with_vex(params)
  end

  test "validates a mapping compliant object (with module options)" do
    Application.put_env(:graveyard, :mappings, module_mappings())
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()

    params = %{
      favourite_drag_queen: "Naomi Smalls"
    }
    assert Graveyard.ORM.Validation.validate_with_vex(params)
  end

  test "does not validate a non-compliant object (basic category)" do
    Application.put_env(:graveyard, :mappings, simple_mappings())
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()
    
    params = %{
      favourite_drag_queen: "Next american drag super star"
    }
    refute Graveyard.ORM.Validation.validate_with_vex(params)
  end

  test "does not validate a non-compliant object (no module loaded)" do
    Application.put_env(:graveyard, :mappings, mappings_with_no_module())
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()

    params = %{
      favourite_drag_queen: "Raja"
    }
    assert_raise RuntimeError, fn -> Graveyard.ORM.Validation.validate_with_vex(params) end
  end

  test "does not validate a non-compliant object (no module function found)" do
    Application.put_env(:graveyard, :mappings, mappings_with_module_with_no_function())
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()

    params = %{
      favourite_drag_queen: "Raja"
    }
    assert_raise RuntimeError, fn -> Graveyard.ORM.Validation.validate_with_vex(params) end
  end

end