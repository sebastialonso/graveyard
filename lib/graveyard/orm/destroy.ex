defmodule Graveyard.ORM.Destroy do
  defmacro __using__(_) do
    quote do
      alias Graveyard.Support
      alias Graveyard.Record
      import Graveyard.Utils
      import Tirexs.HTTP

      def destroy(id, opts \\ %{}) do
        do_destroy(id, opts)
      end

      defp do_destroy(id, opts) do
        %{index: index, type: type} = Map.merge(
          %{index: Support.index(), type: Support.type()}, 
          opts
        )
        # IO.inspect Application.get_all_env(:tirexs)
        deleted = Record.find(id)
        case delete("#{index}/#{type}/#{id}") do
          {:ok, 200, object} ->
            deleted
          {:error, 404, error} ->
            nil
          {:error, status, error} ->
            IO.inspect(status)
            IO.inspect(error)
            # Raise some error
            {:error, error}
          :error ->
            IO.inspect "ERROR"
            raise Graveyard.Errors.ElasticSearchInstanceError
        end
      end
    end
  end
end