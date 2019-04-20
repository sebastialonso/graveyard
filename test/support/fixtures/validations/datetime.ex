defmodule Graveyard.Support.Fixtures.Validations.Datetime do
  def simple_mappings do
    %{
      "logged_at" => %{"type" => :datetime}
    }
  end
end