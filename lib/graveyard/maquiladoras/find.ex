defmodule Graveyard.Maquiladoras.Find do
  def maquilate(result) do
    result
    |> Map.get(:_source)
    |> Map.put(:id, result._id)
    |> Map.delete(:__aux)
  end
end