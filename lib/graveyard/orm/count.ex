defmodule Graveyard.ORM.Count do
  defmacro __using__(_) do
    quote do
      alias Graveyard.Support
      import Tirexs.HTTP

      def count() do
        case Tirexs.HTTP.post("#{Support.index()}/#{Support.type()}/_count") do
          {:ok, 200, %{count: count}} -> count
          {:error, status, error} -> 
            IO.inspect status
            IO.inspect error
            0
        end
      end
    end
  end
end