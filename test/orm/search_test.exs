defmodule Graveyard.ORM.SearchTest do
  use ExUnit.Case

  alias Graveyard.Record
  alias Graveyard.Support
  alias Graveyard.Utils.TirexsUris

  @mappings %{
    "title" => %{"type" => :text},
    "content" => %{"type" => :text},
    "color" => %{"type" => :category},
    "published_at" => %{"type" => :date},
  }

  setup do
    Application.put_env(:graveyard, :index, "graveyard_test")
    Application.put_env(:graveyard, :type, "graveyard_test")
    Application.put_env(:graveyard, :mappings_module, nil)
    Application.put_env(:graveyard, :mappings, @mappings)
    
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()


    docs = Enum.map(1..12, fn(i) -> 
      color = if rem(i, 2) == 1 do
        "green"
      else
        "red"
      end
      published_at = if rem(i, 2) == 1 do
        Timex.now |> Timex.shift(months: 3) |> Timex.format!("%d/%m/%Y", :strftime)
      else
        Timex.now |> Timex.shift(hours: 2) |> Timex.format!("%d/%m/%Y", :strftime)
      end
      {:ok, doc} = Record.insert(%{
        "title" => Faker.Name.name(),
        "content" => Faker.Lorem.Shakespeare.hamlet(),
        "color" => color,
        "published_at" => published_at
      })
      doc
    end)
    [docs: docs]
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
      assert records.current_page == 1
    end

    test "returns second page of results" do
      records = Record.search([], 2, 10)
      assert Enum.count(records.records) == 2
      assert records.current_page == 2
    end

    test "returns match query results" do
      match_filter = %{"type" => "match", "field" => "color", "value" => "red"}
      records = Record.search([match_filter])
      assert Enum.count(records.records) > 0
      assert Enum.count(records.records) < 12
      assert Enum.all?(
        Enum.map(records.records, fn(x) -> x.color == "red" end))
    end

    test "returns range query results" do
      raw_to = Timex.now |> Timex.shift(days: 5)
      formatted_to = raw_to |> Timex.format!("%d/%m/%Y", :strftime)
      raw_from = Timex.now |> Timex.shift(days: -5)
      formatted_from = raw_from |> Timex.format!("%d/%m/%Y", :strftime)
      
      # Get all records with published_at between five days ago and five days in the future
      range_filter = %{"type" => "range", "field" => "published_at", "from" => formatted_from, "to" => formatted_to}
      interval = Timex.Interval.new(from: raw_from, until: [days: 7])
      records = Record.search([range_filter])

      assert Enum.count(records.records) > 0
      assert Enum.count(records.records) < 12
      assert Enum.all?(
        Enum.map(records.records, fn(record) -> 
          timex_date = Timex.parse!(record.published_at, "%d/%m/%Y", :strftime)
          timex_date in interval
        end)
      )
    end

    test "returns ids query results", %{docs: docs} do
      ids_query = %{"type" => "ids", "values" => Enum.take(docs, 2) |> Enum.map(fn(doc) -> doc.id end) }
      records = Record.search([ids_query])

      assert Enum.count(records.records) > 0
      assert Enum.count(records.records) < 12
      assert Enum.all?(
        Enum.map(records.records, fn(record) ->
          Enum.member?(ids_query["values"], record.id)
        end)
      )
    end

    test "returns exists query results" do
      exists_query = %{"type" => "exists", "field" => "title"}
      records = Record.search([exists_query], 1, 12)

      assert Enum.count(records.records) == 12
      
      exists_query = %{"type" => "exists", "field" => "nope"}
      records = Record.search([exists_query])

      assert Enum.count(records.records) == 0
    end
  end

end