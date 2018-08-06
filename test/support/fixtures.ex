defmodule Graveyard.Support.Fixtures do
  alias Graveyard.Record

  def with_nested_oblists_mappings do
    %{
      "sets" => %{"type" => :oblist, "schema" => %{
        "name" => %{"type" => :text},
        "symbol" => %{"type" => :category},
        "examples" => %{"type" => :oblist, "schema" => %{
          "name" => %{"type" => :category},
          "tags" => %{"type" => :list}
        }}
      }}
    }    
  end

  def simple_mappings do
    %{
        "episode" => %{"type" => :text},
        "number" => %{"type" => :integer},
        "hosts" => %{"type" => :list}
      }
  end

  def with_object_mappings do
    %{
        "episode" => %{"type" => :text},
        "number" => %{"type" => :integer},
        "hosts" => %{"type" => :list},
        "topic" => %{"type" => :object, "schema" => %{
          "name" => %{"type" => :category},
          "followers" => %{"type" => :integer},
          "last_time_played" => %{"type" => :date}
        }} 
      }
  end

  def with_oblists_mappings do
    %{
      "episode" => %{"type" => :text},
      "number" => %{"type" => :category},
      "hosts" => %{"type" => :list},
      "duration" => %{"type" => :number},
      "listeners" => %{"type" => :integer},
      "topic" => %{"type" => :object, "schema" => %{
        "name" => %{"type" => :string},
        "followers" => %{"type" => :integer},
        "last_time_played" => %{"type" => :date}
      }},
      "tags" => %{"type" => :oblist, "schema" => %{
        "name" => %{"type" => :category}
      }}
    }
  end

  def episodes do
    [
      %{episode: "Hail Satan!", number: 39, duration: 47, listeners: 1244, topic: %{name: "Satanism", followers: 432, last_time_played: "25/03/2018"},
          tags: [%{name: "Satanism"}, %{name: "Cults"}]},
      %{episode: "The Alien Agenda", number: 40, duration: 42, listeners: 2344, topic: %{name: "Aliens", followers: 234, last_time_played: "01/04/2018"},
          tags: [%{name: "UFO"}, %{name: "Aliens"}]},
      %{episode: "Our psychic powers", number: 41, duration: 25, listeners: 2345, topic: %{name: "Magick", followers: 124, last_time_played: "08/04/2018"},
          tags: [%{name: "Occult"}, %{name: "Magick"}]},
      %{episode: "Ghost, Alien, or Molested", number: 42, duration: 42, listeners: 4567, topic: %{name: "Paranormal", followers: 987, last_time_played: "15/04/2018"},
          tags: [%{name: "Aliens"}, %{name: "Ghosts"}]},
      %{episode: "Occult symbols", number: 43, duration: 38, listeners: 4653, topic: %{name: "Occult", followers: 231, last_time_played: "22/04/2018"},
          tags: [%{name: "Occult"}]},
      %{episode: "A smattering of creppy", number: 44, duration: 56, listeners: 5678, topic: %{name: "Creppypasta", followers: 753, last_time_played: "29/04/2018"},
          tags: [%{name: "Creppypasta"}]},
      %{episode: "Demon Hunters", number: 45, duration: 46, listeners: 5865, topic: %{name: "Paranormal", followers: 834, last_time_played: "06/05/2018"},
          tags: [%{name: "Satanism"}, %{name: "Paranormal"}]},
      %{episode: "Cannibalism", number: 46, duration: 50, listeners: 2345, topic: %{name: "Creepy", followers: 834, last_time_played: "13/05/2018"},
          tags: [%{name: "Fetish"}]},
      %{episode: "Origins of the Pyramids", number: 47, duration: 56, listeners: 6789, topic: %{name: "Occult", followers: 231, last_time_played: "20/05/2018"},
          tags: [%{name: "Occult"}, %{name: "AncientAliens"}]},
      %{episode: "666 The List of the Beast", number: 48, duration: 65, listeners: 8764, topic: %{name: "Satanism", followers: 432, last_time_played: "27/05/2018"},
          tags: [%{name: "Occult"}, %{name: "AncientAliens"}]},
      %{episode: "The Black Monk of Pontefract", number: 240, duration: 64.5, listeners: 12345, topic: %{name: "Paranormal", followers: 834, last_time_played: "03/06/2018"},
        tags: [%{name: "Ghosts"}]},
      %{episode: "Billy Meier - Alien collaborator", number: 239, duration: 71, listeners: 1113, topic: %{name: "Aliens", followers: 234, last_time_played: "10/06/2018"},
        tags: [%{name: "UFO"}, %{name: "Aliens"}]}
    ]
  end

  def create_episodes() do
    Enum.map(episodes(), fn(episode) -> Record.insert(episode) end)  
  end
end