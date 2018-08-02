defmodule Graveyard.ORM.Find do
  @moduledoc """
  Implements the `find` function
  """
  defmacro __using__(_opts) do
    quote do
      def find(id, opts \\ %{}) do
        Graveyard.ORM.Find.find(id, opts)
      end
    end
  end

  alias Graveyard.Support
  import Graveyard.Maquiladoras.Find
  import Tirexs.HTTP

  @doc """
  Find a record by id. Returns the record if existent, `nil` otherwise
  """
  def find(id, opts) do
    default_opts = %{
      index: Support.index(), type: Support.type(), maquilate: true
    }
    opts = Map.merge(default_opts, opts)
    
    case get("#{opts.index}/#{opts.type}/#{id}") do
      :error -> raise Graveyard.Errors.ElasticSearchInstanceError
      {:error, status, object} ->
        if Map.get(opts, :log, false) do
          IO.inspect(status)
          IO.inspect(object)
        end
        nil
      {:ok, 200, object} ->
        if opts.maquilate do
          object |> maquilate
        else
          object
        end
    end
  end
end