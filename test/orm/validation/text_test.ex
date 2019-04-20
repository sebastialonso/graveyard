defmodule Graveyard.ORM.Validation.TextTest do
  use ExUnit.Case

  alias Graveyard.Utils.TirexsUris
  import Graveyard.Support.Fixtures.Validations.Text

  setup do
    Application.put_env(:tirexs, :uri, "http://localhost:9200")
    Application.put_env(:graveyard, :index, "graveyard_test")
    Application.put_env(:graveyard, :type, "graveyard_test")
    Application.put_env(:graveyard, :mappings_module, nil)
    Application.put_env(:graveyard, :validate_before_insert, true)
    Application.put_env(:vex, :sources, [
      [text: Graveyard.Validators.Text],
      Vex.Validators
    ])
    
    :ok
  end

  test "validates a mapping compliant object (type)" do
    Application.put_env(:graveyard, :mappings, simple_mappings())
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()

    params = %{
      name: "Henry"
    }

    assert Graveyard.ORM.Validation.validate_with_vex(params)
  end

  test "does not validate a non-compliant object (type)" do
    Application.put_env(:graveyard, :mappings, simple_mappings())
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()
    
    params = %{
      name: 1
    }
    refute Graveyard.ORM.Validation.validate_with_vex(params)
  end

  test "validates a mapping compliant object (format)" do
    Application.put_env(:graveyard, :mappings, format_mappings())
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()

    params = %{
      name: "This name has_regex in it"
    }

    assert Graveyard.ORM.Validation.validate_with_vex(params)
  end

  test "does not validate a non-compliant object (format)" do
    Application.put_env(:graveyard, :mappings, format_mappings())
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()
    
    params = %{
      name: "This name has no regex in it"
    }
    
    refute Graveyard.ORM.Validation.validate_with_vex(params)
  end


end