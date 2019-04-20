defmodule Graveyard.Support.Fixtures.Validation do
  def simple_mappings do
    %{
      "name" => %{"type" => :text},
      "age" => %{"type" => :integer, "greater_than" => 20},
      "favourite_number" => %{"type" => :number, "less_than_or_equal_to" => 3.14}
    }
  end

  def mappings_with_no_module do
    %{
      "favourite_drag_queen" => %{"type" => :category, "within_module" => NotModuleHere}
    }
  end
end