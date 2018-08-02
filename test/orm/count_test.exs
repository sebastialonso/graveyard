defmodule Graveyard.ORM.CountTest do
  use ExUnit.Case

  alias Graveyard.Record
  alias Graveyard.Support
  alias Graveyard.Utils.TirexsUris

  defmodule CustomMappings do
    import Tirexs.Mapping

    def get_mappings(index_name, type_name) do
      index = [index: index_name, type: type_name]
      mappings do
        indexes "title", type: "text"
        indexes "content", type: "text", analyzer: "nGram_analyzer"
      end
    end
  end

  @mappings %{
    "title" => %{"type" => :text},
    "content" => %{"type" => :text}
  }

  setup do
    Application.put_env(:tirexs, :uri, "http://localhost:9200")
    Application.put_env(:graveyard, :index, "graveyard_test")
    Application.put_env(:graveyard, :type, "graveyard_test")
    Application.put_env(:graveyard, :mappings_module, nil)
    Application.put_env(:graveyard, :mappings, @mappings)
    
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()

    Enum.each(1..5, fn(_) -> 
      Record.insert(%{
        "title" => Faker.Name.name(),
        "content" => Faker.Lorem.Shakespeare.hamlet()
      })
    end)
    :ok
  end

  describe "count/0" do
    test "returns count of all elements" do
      assert Record.count() == 5
    end
  end
end