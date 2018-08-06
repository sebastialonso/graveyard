defmodule Graveyard.ORM.SearchTest do
  use ExUnit.Case

  alias Graveyard.Record
  alias Graveyard.Support
  alias Graveyard.Utils.TirexsUris
  alias Graveyard.Support.Fixtures

  setup do
    Application.put_env(:graveyard, :index, "graveyard_test")
    Application.put_env(:graveyard, :type, "graveyard_test")
    Application.put_env(:graveyard, :mappings_module, nil)
    Application.put_env(:graveyard, :mappings, Fixtures.with_oblists_mappings())
    
    TirexsUris.delete_mapping()
    Graveyard.Mappings.create_settings_and_mappings()

    [docs: Enum.map(Fixtures.create_episodes(), fn(x) -> 
      {:ok, doc} = x 
      doc
    end)]
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
      match_filter = %{"type" => "match", "field" => "episode", "value" => "alien"}
      records = Record.search([match_filter])
      assert Enum.count(records.records) > 0
      assert Enum.count(records.records) < 12
      assert Enum.all?(
        Enum.map(records.records, fn(x) -> String.downcase(x.episode) =~ "alien" end))
    end

    test "returns range query results" do
      # TODO take value from Fixtures.episodes |> List.first |> Map.get :topic |> Map.get :last_time_played
      raw_from = ~D[2018-03-20] 
      formatted_from = raw_from |> Timex.format!("%d/%m/%Y", :strftime)
      # TODO take value from second element of Fixtures.episodes
      raw_to = ~D[2018-04-03]
      formatted_to = raw_to |> Timex.format!("%d/%m/%Y", :strftime)
      
      # Get all records with published_at between five days ago and five days in the future
      range_filter = %{"type" => "range", "field" => "topic.last_time_played", "from" => formatted_from, "to" => formatted_to}
      interval = Timex.Interval.new(from: raw_from, until: [days: 15])
      records = Record.search([range_filter])

      assert Enum.count(records.records) > 0
      assert Enum.count(records.records) < 12
      assert Enum.all?(
        Enum.map(records.records, fn(record) -> 
          timex_date = Timex.parse!(record.topic.last_time_played, "%d/%m/%Y", :strftime)
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
      exists_query = %{"type" => "exists", "field" => "episode"}
      records = Record.search([exists_query], 1, 12)

      assert Enum.count(records.records) == 12
      
      exists_query = %{"type" => "exists", "field" => "nope"}
      records = Record.search([exists_query])

      assert Enum.count(records.records) == 0
    end

    test "returns nested query results" do
      nested_query = %{"type" => "nested", "path" => "tags", "queries" => [
        %{"type" => "match", "field" => "name", "value" => "UFO"}
      ]}
      records = Record.search([nested_query])

      assert Enum.count(records.records) > 0
      assert Enum.count(records.records) < 12
      assert Enum.any?(
        Enum.map(records.records, fn(record) ->
          Enum.map(record.tags, fn(tag) -> 
            tag.name =~ "UFO"
          end)
        end) |> List.flatten
      )
    end
  end
end