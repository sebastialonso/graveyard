defmodule Graveyard.Support.Fixtures.Validations.Number do
  def simple_mappings do
    %{
      "lucky_number" => %{"type" => :number}
    }
  end

  def equal_to_mappings do
    %{
      "lucky_number" => %{"type" => :number, "equal_to" => 13.5}
    }
  end

  def greater_than_mappings do
    %{
      "lucky_number" => %{"type" => :number, "greater_than" => 13.5}
    }
  end

  def less_than_mappings do
    %{
      "lucky_number" => %{"type" => :number, "less_than" => 13.5}
    }
  end

  def greater_than_or_equal_to_mappings do
    %{
      "lucky_number" => %{"type" => :number, "greater_than_or_equal_to" => 13.5}
    }
  end

  def less_than_or_equal_to_mappings do
    %{
      "lucky_number" => %{"type" => :number, "less_than_or_equal_to" => 13.5}
    }
  end
end