defmodule Graveyard.Support.Fixtures.Validations.Category do
  def simple_mappings do
    %{
      "favourite_drag_queen" => %{"type" => :category, "within" => ["RuPaul", "Raja"]}
    }
  end

  def module_mappings do
    %{
      "favourite_drag_queen" => %{"type" => :category, "within_module" => Graveyard.ORM.Validation.CategoryTest.Dragqueens}
    }
  end

  def mappings_with_no_module do
    %{
      "favourite_drag_queen" => %{"type" => :category, "within_module" => NotModuleHere}
    }
  end

  def mappings_with_module_with_no_function do
    %{
      "favourite_drag_queen" => %{"type" => :category, "within_module" => Graveyard.ORM.Validation.CategoryTest.NotFunctionHere}
    }
  end
end