defmodule Graveyard.ORM.Update do
  defmacro __using__(_opts) do
    quote do
      def update(id, params) do
        Graveyard.ORM.Update.update(id, params) 
      end
    end
  end

  alias Graveyard.{Support, Record}
  alias Graveyard.Utils.TirexsUris
  import Graveyard.Utils
  import Tirexs.HTTP

  def update(id, params) do
    case Record.find(id) do
      nil -> nil
      record ->
        updated = record
        |> Map.drop([:id])
        |> Map.merge(to_indifferent_map(params))
        |> Map.put(:updated_at, now)
        
        case TirexsUris.update(id, updated) do
          {:ok, 200, %{_id: id}} ->
            {:ok, Record.find(id)}
          {:error, status, reason} ->
            IO.inspect status
            IO.inspect reason
            {:error, reason}
        end
    end
  end
end