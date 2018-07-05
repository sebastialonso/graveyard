defmodule Graveyard.RecordTest do
  use ExUnit.Case
  
  @module Graveyard.Record

  test "has find/1 function" do
    assert @module.__info__(:functions) |> Enum.find(fn tuple -> tuple == {:find, 1} end)
  end

  test "has find/2 function" do
    assert @module.__info__(:functions) |> Enum.find(fn tuple -> tuple == {:find, 2} end)
  end

  test "has insert/1 function" do
    assert @module.__info__(:functions) |> Enum.find(fn tuple -> tuple == {:insert, 1} end)
  end

  test "has insert/2 function" do
    assert @module.__info__(:functions) |> Enum.find(fn tuple -> tuple == {:insert, 2} end)
  end
end