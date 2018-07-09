defmodule Graveyard.Utils do
  @moduledoc """
  Various utility functions
  """
  def to_keyword_list(map) do
    Enum.map(map, fn({key, value}) ->
      case value do
        [h | _] = value when is_list(value) and is_map(h) ->
          {
            to_indifferent_atom(key), 
            Enum.map(value, fn(inner_map) -> 
              to_keyword_list(inner_map)
            end)
          }
        %{} ->
          {to_indifferent_atom(key), to_keyword_list(value)}
        _ ->
          {to_indifferent_atom(key), value}
      end
    end)
  end

  def to_indifferent_map(map) do
    Map.new(map, fn {key, value} -> 
      cond do
        is_list(value) and Enum.all?(value, fn(x) -> is_map(x) end) ->
          mmaps = Enum.map(value, fn(each_value) -> 
            to_indifferent_map(each_value)
          end)
          {to_indifferent_atom(key), mmaps}
        is_map(value) ->
          {to_indifferent_atom(key), to_indifferent_map(value)}
        is_atom(key) or is_binary(key) -> {to_indifferent_atom(key), value}
        true -> {key, value}  
      end
    end)
  end

  def to_indifferent_atom(key) do
    cond do
      is_atom(key) -> key
      is_binary(key) -> String.to_atom(key)
      true -> key
    end
  end
end