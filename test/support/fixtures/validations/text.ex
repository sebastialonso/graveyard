defmodule Graveyard.Support.Fixtures.Validations.Text do
  def simple_mappings do
    %{
      "name" => %{"type" => :text}
    }
  end

  def format_mappings do
    %{
      "name" => %{"type" => :text, "format" => ~r/has_regex/}
    }
  end
end