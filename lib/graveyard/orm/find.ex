defmodule Graveyard.ORM.Find do
  @moduledoc """
  Implements the `find` function
  """
  defmacro __using__(_opts) do
    quote do
      alias Graveyard.Support
      import Tirexs.HTTP

      @doc """
      Find a record by id. Returns the record if existent, `nil` otherwise
      """
      def find(id, opts \\ %{}) do
        %{index: index, type: type} = Map.merge(%{index: Support.index(), type: Support.type()}, opts)
        
        case get("#{index}/#{type}/#{id}") do
          {:error, status, object} ->
            if Map.get(opts, :log, false) do
              IO.inspect(status)
              IO.inspect(object)
            end
            nil
          {:ok, 200, object} ->
            Map.get(object, :_source)
              |> Map.put(:id, object._id)
        end
      end
    end
  end
end