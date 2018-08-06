defmodule Graveyard.Mappings.Basic do
  @moduledoc """
  Builds a mapping object from a user-supplied module
  """
  alias Graveyard.Support
  alias Graveyard.Errors

  def get_mappings(index_name, type_name) do
    module = Support.mappings_module
    try do
      module.get_mappings(index_name, type_name)
    rescue
      e in UndefinedFunctionError ->
        raise Errors.ConfigModuleError
    end  
  end
end