defmodule Graveyard.Support.Fixtures.Validations.Date do
  def simple_mappings do
    %{
      "birthday" => %{"type" => :date}
    }
  end
end