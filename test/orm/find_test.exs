defmodule Graveyard.ORM.FindTest do
  use ExUnit.Case

  alias Graveyard.Record
  alias Graveyard.Support

  setup do
    record = %{
      "name" => "Henry",
      "description" => "It's the Bilderberg group!"
    }
    {:ok, 201, es_object} = Tirexs.HTTP.post("#{Support.index()}/#{Support.type()}", record)

    [record: es_object]
  end

  test "finds an existing record by id", %{record: record} do
    object = Record.find(record._id)
    assert object
    assert object.id
  end

  test "returns nil when non-existent id", %{record: record} do
    object = Record.find(999)
    refute object
  end
end