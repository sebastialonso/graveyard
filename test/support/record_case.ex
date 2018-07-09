defmodule Graveyard.RecordCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Graveyard.Support
      alias Graveyard.Record
    end
  end

  setup do
    index = Application.get_env(:graveyard, :index)
    Tirexs.HTTP.delete(index)
    # Probably is good idea to remake the indexes here
    # From values coming from a Helper
    :ok
  end
end