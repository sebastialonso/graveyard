defmodule Graveyard.ORM.GroupTest do
  use ExUnit.Case

  alias Graveyard.ORM.Group
  alias Graveyard.Errors
  alias Graveyard.Record
  alias Graveyard.Utils.TirexsUris

  @mappings %{
    "episode" => %{"type" => :text},
    "number" => %{"type" => :integer},
    "hosts" => %{"type" => :list},
    "topic" => %{"type" => :object, "schema" => %{
      "name" => %{"type" => :string},
      "followers" => %{"type" => :integer},
      "last_time_played" => %{"type" => :date}
    }},
    "tags" => %{"type" => :oblist, "schema" => %{
      "name" => %{"type" => :string}
    }}
  }

  describe "group/3" do
    setup do
      Application.put_env(:graveyard, :index, "graveyard_test")
      Application.put_env(:graveyard, :type, "graveyard_test")
      Application.put_env(:graveyard, :mappings, @mappings)
      
      TirexsUris.delete_mapping()
      Graveyard.Mappings.get_mappings()
      Graveyard.Mappings.create_settings_and_mappings()

      Record.insert(
        %{episode: "Hail Satan!", number: 39, topic: %{name: "Satanism", followers: 432, last_time_played: "25/03/2018"},
          tags: [%{name: "Satanism"}, %{name: "Cults"}]})
      Record.insert(
        %{episode: "Bigfoot", number: 40, topic: %{name: "TheAlienAgenda", followers: 234, last_time_played: "01/06/2018"},
          tags: [%{name: "UFO"}, %{name: "Aliens"}]})
      Record.insert(
        %{episode: "Our psychic powers", number: 41, topic: %{name: "Magick", followers: 124, last_time_played: "13/05/2018"},
          tags: [%{name: "Occult"}, %{name: "Magick"}]})
      Record.insert(
        %{episode: "Ghost, Alien, or Molested", number: 42, topic: %{name: "Paranormal", followers: 987, last_time_played: "13/05/2018"},
          tags: [%{name: "Aliens"}, %{name: "Ghosts"}]})
      Record.insert(
        %{episode: "Occult symbols", number: 43, topic: %{name: "Occult", followers: 231, last_time_played: "7/05/2018"},
          tags: [%{name: "Occult"}]})
      Record.insert(
        %{episode: "A smattering of creppy", number: 44, topic: %{name: "Creppypasta", followers: 753, last_time_played: "7/05/2018"},
          tags: [%{name: "Creppypasta"}]})
      Record.insert(
        %{episode: "Demon Hunters", number: 45, topic: %{name: "Paranormal", followers: 834, last_time_played: "7/05/2018"},
          tags: [%{name: "Satanism"}, %{name: "Paranormal"}]})
    end

    test "raises when :aggs argument is not a list" do
      assert_raise Errors.BadArgument, fn -> Record.group([], "sdsf", %{}) end
      assert_raise Errors.BadArgument, fn -> Record.group([], 1, %{}) end
      assert_raise Errors.BadArgument, fn -> Record.group([], %{}, %{}) end
      assert_raise Errors.BadArgument, fn -> Record.group([], nil, %{}) end
    end

    test "" do
      
    end

    test "returns an array of objects with :data and :source keys" do
      actual = Record.group([], [%{"type" => "simple", "key" => "topic.name"}])
      assert Enum.all?(actual, fn(elem) -> 
        Map.has_key?(elem, :source) and Map.has_key?(elem, :data)
      end)

      actual = Record.group([], [%{"type" => "range", "key" => "topic.followers", "opts" => %{"min" => 200, "step" => 100, "max" => 800}}])
      assert Enum.all?(actual, fn(elem) -> 
        Map.has_key?(elem, :source) and Map.has_key?(elem, :data)
      end)
    end
  end
end