defmodule Graveyard.ORM.Insert do
  @moduledoc """
  Implements the `insert` function
  """
  defmacro __using__(_) do
    quote do
      alias unquote(Graveyard.Support)
      alias unquote(Graveyard.Record)
      import unquote(Graveyard.Utils)
      import unquote(Tirexs.HTTP)

      @doc """
      Stores a map into ElasticsSearch. Returns {:ok, record} if success, {:error, error} otherwise
      """
      def insert(raw, opts \\ %{}) do
        do_save(raw, opts)
      end

      defp do_save(raw, opts) do
        %{index: index, type: type} = Map.merge(
          %{index: Support.index(), type: Support.type()}, 
          opts
        )
        case post("#{index}/#{type}", raw) do
          {:ok, 201, object} ->
            {:ok, Record.find(object._id, %{index: index, type: type})}
          {:error, status, error} ->
            IO.inspect(status) 
            IO.inspect(error) 
            {:error, error}
        end
      end
    end
  end
end