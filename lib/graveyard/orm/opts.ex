defmodule Graveyard.ORM.Opts do
  defmodule Search do
    def options(opts), do: Map.merge(search_defaults, opts)
    def search_defaults do
      %{
        sort: [%{created_at: "desc"}],
        maquilate: true
      }
    end
  end
end