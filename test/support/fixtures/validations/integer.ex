defmodule Graveyard.Support.Fixtures.Validations.Integer do
  def simple_mappings do
    %{
      "lucky_number" => %{"type" => :integer}
    }
  end

  def equal_to_mappings do
    %{
      "lucky_number" => %{"type" => :integer, "equal_to" => 13}
    }
  end

  def greater_than_mappings do
    %{
      "lucky_number" => %{"type" => :integer, "greater_than" => 13}
    }
  end

  def less_than_mappings do
    %{
      "lucky_number" => %{"type" => :integer, "less_than" => 13}
    }
  end

  def greater_than_or_equal_to_mappings do
    %{
      "lucky_number" => %{"type" => :integer, "greater_than_or_equal_to" => 13}
    }
  end

  def less_than_or_equal_to_mappings do
    %{
      "lucky_number" => %{"type" => :integer, "less_than_or_equal_to" => 13}
    }
  end
end