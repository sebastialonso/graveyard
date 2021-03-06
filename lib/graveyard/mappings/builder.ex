defmodule Graveyard.Mappings.Builder do
  @moduledoc """
  Builds a mapping object from a user-supplied map schema using the Graveyard Mapping DSL
  """

  alias Graveyard.Support
  alias Graveyard.Utils

  def get_mappings(index_name, type_name) do
    [index: index_name, type: type_name, 
      mapping: build_recursively(Support.mappings)]
  end

  defp build_recursively(config) do
    [{:properties, Enum.map(config, fn({key, value}) -> 
      if Map.has_key?(value, "schema") do
        {
          Utils.to_indifferent_atom(key), 
          Utils.to_keyword_list(graveyard_to_elastic(value["type"])) ++ build_recursively(value["schema"])
        }
      else
        {Utils.to_indifferent_atom(key), graveyard_to_elastic(value["type"])}
      end 
    end)
    }]
  end

  def timestamps() do
     Utils.to_keyword_list(%{
      created_at: graveyard_to_elastic(:datetime),
      updated_at: graveyard_to_elastic(:datetime)
    })
  end

  defp graveyard_to_elastic(type) do
    case type do
      :string -> [type: "keyword"]
      :category -> [type: "keyword"]
      :list -> [type: "keyword"]
      :text -> [type: "text", analyzer: "nGram_analyzer"]
      :date -> [type: "date", format: Support.date_elasticsearch_format()]
      :datetime -> [type: "date", format: Support.datetime_elasticsearch_format()]
      :integer -> [type: "integer"]
      :number -> [type: "float"]
      :object -> [type: "object"]
      :oblist -> [type: "nested"]
    end
  end
end