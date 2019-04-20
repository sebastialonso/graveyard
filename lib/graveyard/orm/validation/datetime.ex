defmodule Graveyard.Validators.Datetime do
  use Vex.Validator
  alias Graveyard.Support
  @option_keys [
    :is
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

  defp do_validate(value, :is, true) do
    case {is_binary(value), Regex.match?(Support.datetime_format(), value)} do
      {true, true} -> :ok
      _ -> {:error, "must be a valid date"}
        
    end
  end
end