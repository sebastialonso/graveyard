defmodule Graveyard.ORM.Opts do
  defmodule Search do
    alias Graveyard.Utils
    def options(opts \\ %{}), do: Map.merge(search_defaults, Utils.to_indifferent_map(opts))
    def search_defaults do
      %{
        sort: [%{created_at: "desc"}],
        maquilate: true
      }
    end
  end

  defmodule Insert do
    alias Graveyard.{Utils, Support}
    def options(opts \\ %{}), do: Map.merge(insert_defaults, Utils.to_indifferent_map(opts))
    def insert_defaults do
      %{
        index: Support.index(),
        type: Support.type(),
        validate_before_insert: Support.validate_before_insert()
      }
    end
  end

  defmodule Update do
    alias Graveyard.{Utils, Support}
    def options(opts \\ %{}), do: Map.merge(insert_defaults, Utils.to_indifferent_map(opts))
    def insert_defaults do
      %{
        index: Support.index(),
        type: Support.type(),
        validate_before_update: Support.validate_before_update()
      }
    end
  end
end