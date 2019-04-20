defmodule Graveyard.Validators.Category do
  use Vex.Validator

  alias Graveyard.Validators.Category.Utils
  @option_keys [
    :within,
    :within_module
  ]

  def validate(value, options) when is_list(options) do
    Enum.reduce_while(options, :ok, fn 
      {k, o}, _ when k in @option_keys ->
        case do_validate(value, k, o) do
          :ok ->
            {:cont, :ok}
          {:error, message} ->
            {:halt, {:error, message}}
        end
      _, _ -> {:cont, :ok}
    end)
  end
  
  def do_validate(value, :within, o) do
     case Enum.member?(o, value) do
       true -> :ok
       _ -> {:error, "must be on of allowed values"}
     end
  end

  def do_validate(value, :within_module, module) do
     case Utils.module_compiled?(module) do
       false -> raise "Module supplied not compiled"
       true -> 
          case function_exported? module, :options, 0 do
            false -> raise "Module supplied does not implement options/0"
            true -> 
              options = apply(module, :options, [])
              do_validate(value, :within, options)
          end
     end
  end
end

defmodule Graveyard.Validators.Category.Utils do
  def module_compiled?(module) do
    function_exported?(module, :__info__, 1)
  end
end