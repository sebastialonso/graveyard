defmodule Graveyard.ORM.Validation.Date do
  use ExUnit.Case

  alias Graveyard.Utils.TirexsUris
  import Graveyard.Support.Fixtures.Validations.Date
  @format ~r/^(-?(?:[1-9][0-9]*)?[0-9]{4})-(1[0-2]|0[1-9])-(3[01]|0[1-9]|[12][0-9])$/
  
  setup do
    Application.put_env(:tirexs, :uri, "http://localhost:9200")
    Application.put_env(:graveyard, :index, "graveyard_test")
    Application.put_env(:graveyard, :type, "graveyard_test")
    Application.put_env(:graveyard, :mappings_module, nil)
    Application.put_env(:graveyard, :date_format, @format)
    Application.put_env(:graveyard, :validate_before_insert, true)
    Application.put_env(:graveyard, :mappings, simple_mappings())
    
    Application.put_env(:vex, :sources, [
      [date: Graveyard.Validators.Date],
      Vex.Validators
    ])

    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()
    
    :ok
  end

  test "validates a mapping compliant object (type)" do
    params = %{
      birthday: "2019-04-20"
    }

    assert Graveyard.ORM.Validation.validate_with_vex(params)
  end

  test "does not validate a non-compliant object (type)" do
    params = %{
      birthday: "20/04/2019"
    }
    refute Graveyard.ORM.Validation.validate_with_vex(params)
  end
end