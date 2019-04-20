defmodule Graveyard.Validators.Text do
  use Vex.Validator

  @option_keys [
    :is,
    :format
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

  defp do_validate(value, :is, true) when is_binary(value), do: :ok
  defp do_validate(value, :is, o), do: {:error, "must be text"} 

  defp do_validate(value, :format, format) do
    case Regex.match?(format, value) do
      true -> :ok
      false -> {:error, "must follow format"}
    end
  end
end