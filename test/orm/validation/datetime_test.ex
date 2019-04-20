defmodule Graveyard.ORM.Validation.Datetime do
  use ExUnit.Case

  alias Graveyard.Utils.TirexsUris
  import Graveyard.Support.Fixtures.Validations.Datetime
  @format ~r/^(-?(?:[1-9][0-9]*)?[0-9]{4})-(1[0-2]|0[1-9])-(3[01]|0[1-9]|[12][0-9])T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\\.[0-9]+)?(Z)?$/
  
  setup do
    Application.put_env(:tirexs, :uri, "http://localhost:9200")
    Application.put_env(:graveyard, :index, "graveyard_test")
    Application.put_env(:graveyard, :type, "graveyard_test")
    Application.put_env(:graveyard, :mappings_module, nil)
    Application.put_env(:graveyard, :datetime_format, @format)
    Application.put_env(:graveyard, :validate_before_insert, true)
    Application.put_env(:graveyard, :mappings, simple_mappings())
    
    Application.put_env(:vex, :sources, [
      [datetime: Graveyard.Validators.Datetime],
      Vex.Validators
    ])

    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()
    
    :ok
  end

  test "validates a mapping compliant object (type)" do
    params = %{
      logged_at: "2019-04-20T20:00:00"
    }

    assert Graveyard.ORM.Validation.validate_with_vex(params)
  end

  test "does not validate a non-compliant object (type)" do
    params = %{
      logged_at: "2019-04-20 20:00:01"
    }
    refute Graveyard.ORM.Validation.validate_with_vex(params)

    params = %{
      logged_at: "20-04-2019 8:00:01"
    }
    refute Graveyard.ORM.Validation.validate_with_vex(params)
  end
end