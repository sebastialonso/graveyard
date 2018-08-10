defmodule Graveyard.ORM.Bulk.InsertTest do
  use ExUnit.Case

  alias Graveyard.{Support.Fixtures, Utils.TirexsUris, ORM.Bulk.Insert}
  alias Graveyard.ORM.Opts.Insert, as: InsertOpts

  describe "insert/2" do
    setup do
      Application.put_env(:tirexs, :uri, "http://localhost:9200")
      Application.put_env(:graveyard, :index, "graveyard_test")
      Application.put_env(:graveyard, :type, "graveyard_test")
      Application.put_env(:graveyard, :mappings_module, nil)
      Application.put_env(:graveyard, :mappings, Fixtures.with_oblists_mappings())
      TirexsUris.delete_mapping(Graveyard.Support.index())
      Graveyard.Mappings.create_settings_and_mappings()
      :ok
    end

    test "creates many documents" do
      episodes = Fixtures.episodes()
      old_count = Graveyard.Record.count()
      actual = Insert.insert(episodes, InsertOpts.options())
      assert old_count + Enum.count(episodes) == Enum.count(actual)
    end

    test "documents are stored with the __aux field" do
      episodes = Fixtures.episodes()
      old_count = Graveyard.Record.count()
      actual = Graveyard.Record.search([], 1, 10, %{maquilate: false})
      assert Enum.all?(actual.records, fn(x) ->
        aux = x |> Map.get(:_source) |> Map.get(:__aux)
        assert aux
        Enum.count(aux) > 0
      end)
    end

    test "raise exception if supplied with a non-list argument" do
      assert_raise Graveyard.Errors.BadArgumentError, fn() -> 
        Insert.insert(1, InsertOpts.options())
      end
      assert_raise Graveyard.Errors.BadArgumentError, fn() -> 
        Insert.insert("asda", InsertOpts.options())
      end
      assert_raise Graveyard.Errors.BadArgumentError, fn() -> 
        Insert.insert([1, "asdada"], InsertOpts.options())
      end
      episode = Fixtures.episodes() |> List.first
      assert_raise Graveyard.Errors.BadArgumentError, fn() -> 
        Insert.insert(episode, InsertOpts.options())
      end
      assert_raise Graveyard.Errors.BadArgumentError, fn() -> 
        Insert.insert([episode, "asdada"], InsertOpts.options())
      end
    end
  end
end