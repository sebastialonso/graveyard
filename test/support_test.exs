defmodule Graveyard.SupportTest do
  use ExUnit.Case

  alias Graveyard.Support

  test "returns configured index" do
    actual = Application.get_env(:graveyard, :index)
    assert Support.index() == actual
  end

  test "returns configured type" do
    actual = Application.get_env(:graveyard, :type)
    assert Support.type() == actual
  end

  test "returns configured mappings" do
    actual = Application.get_env(:graveyard, :mappings)
    assert Support.mappings() == actual
  end
end