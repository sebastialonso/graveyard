defmodule Graveyard.ORM.Update do
  defmacro __using__(_opts) do
    quote do
      alias Graveyard.{Support, Record}
      alias Graveyard.Utils
      alias Graveyard.Utils.TirexsUris
      import Tirexs.HTTP

      def update(id, params) do
        case Record.find(id) do
          nil -> nil
          record ->
            updated = record
            |> Map.drop([:id])
            |> Map.merge(Utils.to_indifferent_map(params))
            
            case TirexsUris.update(id, params) do
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
  end
end