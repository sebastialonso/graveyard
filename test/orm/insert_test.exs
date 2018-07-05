defmodule Graveyard.ORM.InsertTest do
  use ExUnit.Case

  alias Graveyard.Record
  alias Graveyard.Support

  test "inserts a record" do
    record = %{
      "name" => "Henry",
      "description" => "It's the Bilderberg group!"
    }
    
    assert {:ok, %{id: _}} = Record.insert(record)
  end
end