defmodule Graveyard.Validators.Number do
  @moduledoc """
  # Adding a new validator

  To add a new validation criteria, you must:
  * Add the new criteria to the @option_keys list
  * Implement one function which returns either :ok or {:error, message} 
  """
  use Vex.Validator

  @option_keys [
    :is,
    :equal_to,
    :greater_than,
    :less_than,
    :greater_than_or_equal_to,
    :less_than_or_equal_to
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
  
  defp do_validate(value, :is, true) when is_float(value), do: :ok
  defp do_validate(value, :is, _), do: {:error, "must be non-integer number"}
    
  defp do_validate(v, :equal_to, o) when is_float(v) and v == o, do: :ok
  defp do_validate(_, :equal_to, o), do: {:error, "must be a non-integer number equal to #{o}"}
  
  defp do_validate(v, :greater_than, o) when is_float(v) and v > o, do: :ok
  defp do_validate(_, :greater_than, o), do: {:error, "must be a non-integer number greater than #{o}"}
  
  defp do_validate(v, :less_than, o) when is_float(v) and v < o, do: :ok
  defp do_validate(_, :less_than, o), do: {:error, "must be a non-integer number less than #{o}"}

  defp do_validate(v, :greater_than_or_equal_to, o) when is_float(v) and v >= o, do: :ok
  defp do_validate(_, :greater_than_or_equal_to, o),
    do: {:error, "must be a non-integer number greater than or equal to #{o}"}
  
  defp do_validate(v, :less_than_or_equal_to, o) when is_float(v) and v <= o, do: :ok
  defp do_validate(_, :less_than_or_equal_to, o),
    do: {:error, "must be a non-integer number less than or equal to #{o}"}
end