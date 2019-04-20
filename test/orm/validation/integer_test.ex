defmodule Graveyard.ORM.Validation.Integer do
  use ExUnit.Case

  alias Graveyard.Utils.TirexsUris
  import Graveyard.Support.Fixtures.Validations.Integer
  
  setup do
    Application.put_env(:tirexs, :uri, "http://localhost:9200")
    Application.put_env(:graveyard, :index, "graveyard_test")
    Application.put_env(:graveyard, :type, "graveyard_test")
    Application.put_env(:graveyard, :mappings_module, nil)
    Application.put_env(:graveyard, :validate_before_insert, true)
    
    Application.put_env(:vex, :sources, [
      [integer: Graveyard.Validators.Integer],
      Vex.Validators
    ])
    
    :ok
  end

  test "validates a mapping compliant object (type)" do
    Application.put_env(:graveyard, :mappings, simple_mappings())
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()

    params = %{
      lucky_number: 13
    }

    assert Graveyard.ORM.Validation.validate_with_vex(params)
  end

  test "does not validate a non-compliant object (type)" do
    Application.put_env(:graveyard, :mappings, simple_mappings())
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()
    
    params = %{
      lucky_number: 13.5
    }
    refute Graveyard.ORM.Validation.validate_with_vex(params)
  end

  test "validates a mapping compliant object (equal_to)" do

    Application.put_env(:graveyard, :mappings, equal_to_mappings())
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()
    params = %{
      lucky_number: 13
    }

    assert Graveyard.ORM.Validation.validate_with_vex(params)
  end

  test "does not validate a non-compliant object (equal_to)" do
    Application.put_env(:graveyard, :mappings, equal_to_mappings())
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()
    
    params = %{
      lucky_number: 130
    }
    refute Graveyard.ORM.Validation.validate_with_vex(params)
  end

  test "validates a mapping compliant object (greater_than)" do
    Application.put_env(:graveyard, :mappings, greater_than_mappings())
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()
    
    params = %{
      lucky_number: 14
    }

    assert Graveyard.ORM.Validation.validate_with_vex(params)
  end

  test "does not validate a non-compliant object (greater_than)" do
    Application.put_env(:graveyard, :mappings, greater_than_mappings())
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()
    
    params = %{
      lucky_number: 1
    }
    refute Graveyard.ORM.Validation.validate_with_vex(params)
  end

  test "validates a mapping compliant object (less_than)" do
    Application.put_env(:graveyard, :mappings, less_than_mappings())
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()

    params = %{
      lucky_number: 12
    }

    assert Graveyard.ORM.Validation.validate_with_vex(params)
  end

  test "does not validate a non-compliant object (less_than)" do
    Application.put_env(:graveyard, :mappings, less_than_mappings())
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()
    
    params = %{
      lucky_number: 20
    }
    refute Graveyard.ORM.Validation.validate_with_vex(params)
  end

  test "validates a mapping compliant object (greater_than_or_equal_to)" do
    Application.put_env(:graveyard, :mappings, greater_than_or_equal_to_mappings())
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()

    params = %{
      lucky_number: 13
    }

    assert Graveyard.ORM.Validation.validate_with_vex(params)
  end

  test "does not validate a non-compliant object (greater_than_or_equal_to)" do
    Application.put_env(:graveyard, :mappings, greater_than_or_equal_to_mappings())
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()
    
    params = %{
      lucky_number: 1
    }
    refute Graveyard.ORM.Validation.validate_with_vex(params)
  end

  test "validates a mapping compliant object (less_than_or_equal_to)" do
    Application.put_env(:graveyard, :mappings, less_than_or_equal_to_mappings())
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()

    params = %{
      lucky_number: 13
    }

    assert Graveyard.ORM.Validation.validate_with_vex(params)
  end

  test "does not validate a non-compliant object (less_than_or_equal_to)" do
    Application.put_env(:graveyard, :mappings, less_than_or_equal_to_mappings())
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()
    
    params = %{
      lucky_number: 20
    }
    refute Graveyard.ORM.Validation.validate_with_vex(params)
  end
end
