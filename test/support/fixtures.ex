defmodule Graveyard.Support.Fixtures do
  def mappings do
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
      %{episode: "The Alien Agenda", number: 40, duration: 42, listeners: 2344, topic: %{name: "Aliens", followers: 234, last_time_played: "01/06/2018"},
          tags: [%{name: "UFO"}, %{name: "Aliens"}]},
      %{episode: "Our psychic powers", number: 41, duration: 25, listeners: 2345, topic: %{name: "Magick", followers: 124, last_time_played: "13/05/2018"},
          tags: [%{name: "Occult"}, %{name: "Magick"}]},
      %{episode: "Ghost, Alien, or Molested", number: 42, duration: 42, listeners: 4567, topic: %{name: "Paranormal", followers: 987, last_time_played: "13/05/2018"},
          tags: [%{name: "Aliens"}, %{name: "Ghosts"}]},
      %{episode: "Occult symbols", number: 43, duration: 38, listeners: 4653, topic: %{name: "Occult", followers: 231, last_time_played: "7/05/2018"},
          tags: [%{name: "Occult"}]},
      %{episode: "A smattering of creppy", number: 44, duration: 56, listeners: 5678, topic: %{name: "Creppypasta", followers: 753, last_time_played: "7/05/2018"},
          tags: [%{name: "Creppypasta"}]},
      %{episode: "Demon Hunters", number: 45, duration: 46, listeners: 5865, topic: %{name: "Paranormal", followers: 834, last_time_played: "7/05/2018"},
          tags: [%{name: "Satanism"}, %{name: "Paranormal"}]},
      %{episode: "Cannibalism", number: 46, duration: 50, listeners: 2345, topic: %{name: "Creepy", followers: 834, last_time_played: "7/05/2018"},
          tags: [%{name: "Fetish"}]},
      %{episode: "Origins of the Pyramids", number: 47, duration: 56, listeners: 6789, topic: %{name: "Occult", followers: 231, last_time_played: "7/05/2018"},
          tags: [%{name: "Occult"}, %{name: "Ancient Aliens"}]},
      %{episode: "666 The List of the Beast", number: 48, duration: 65, listeners: 8764, topic: %{name: "Satanism", followers: 432, last_time_played: "7/05/2018"},
          tags: [%{name: "Occult"}, %{name: "Ancient Aliens"}]}
    ]
  end
end