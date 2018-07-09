defmodule Graveyard.ORM.SearchTest do
  use ExUnit.Case

  alias Graveyard.Record
  alias Graveyard.Support

  defmodule CustomMappings do
    import Tirexs.Mapping

    def get_mappings(index_name, type_name) do
      index = [index: index_name, type: type_name]
      mappings do
        indexes "title", type: "string"
        indexes "content", type: "string", analyzer: "nGram_analyzer"
        indexes "tag", type: "string"
      end
    end
  end

  setup_all do
    Application.put_env(:graveyard, :index, "graveyard_test")
    Application.put_env(:graveyard, :type, "graveyard_test")
    Application.put_env(:graveyard, :mappings_module, CustomMappings)
    :ok
  end

  setup do
    Tirexs.HTTP.delete(Support.index())
    Enum.each(1..12, fn(i) -> 
      color = if rem(12, i) == 1 do
        "green"
      else
        "red"
      end
      Record.insert(%{
        "title" => Faker.Name.name(),
        "content" => Faker.Lorem.Shakespeare.hamlet(),
        "color" => color
      })
    end)
    :ok
  end

  describe "search/3" do
    test "returns paginated records by default" do
      records = Record.search
      assert records
      assert records.records
      assert Enum.count(records.records) == 10
      assert records.total_pages
      assert is_integer(records.total_pages)
      assert is_integer(records.current_page)
    end

    test "returns second page of results" do
      records = Record.search([], 2, 10)
      assert Enum.count(records.records) == 2
      assert records.current_page == 2
    end

    test "returns match results" do
      match_filter = %{"type" => "match", "field" => "color", "value" => "red"}
      records = Record.search([match_filter])
      assert Enum.count(records.records) > 0
      assert Enum.all?(
        Enum.map(records.records, fn(x) -> x.color == "red" end))
    end
  end

end