defmodule Graveyard.Mappings.Auxiliar do
  
  alias Graveyard.Support
  import Graveyard.Utils

  @doc """
  Traverses recursively the configured mappings map for :oblists objects.
  For every oblist found, the :category and :list fields inside are extracted and turn into an object. 
  Then a special auxiliar field with this object is added to the mappings.
  This is done to make easier the grouping process under nested fields
  """
  def build_auxiliar_mappings(config \\ Support.mappings) do
    grouped_properties = find_fields_with_schema(config) 
      |> Enum.group_by(fn(x) -> 
        x.nested_key
      end)

    properties = Enum.map(grouped_properties, fn({key, val}) -> 
      inner_properties = Enum.reduce(val, [], fn(x, acc) -> 
        acc ++ [{to_indifferent_atom(x.name), [type: "keyword"]}]
      end)
      {to_indifferent_atom(key), [properties: inner_properties, type: "object"]}
    end)
    [__aux: [properties: properties, type: "object"]]
  end

  def find_fields_with_schema(mmap, parent_key \\ "", accumulator \\ []) do
    mmap |> Enum.reduce(accumulator, fn({key, val}, acc) ->
      if is_map(val) do
        if Map.has_key?(val, "schema") do
          parent_key = if parent_key == "" do
            key
          else
            Enum.join([parent_key, key], ".")
          end
          case val["type"] do
            :object ->
              find_fields_with_schema(val["schema"], parent_key, acc)
            :oblist ->
              extract_category_list_keys(key, val["schema"], acc)
            _ -> acc
          end
        else
          acc
        end
      else
        acc
      end
    end)
  end

  def extract_category_list_keys(key, schema, accumulator) do
    schema |> Enum.reduce(accumulator, fn({kkey, value}, acc) -> 
      cond do
        Map.has_key?(value, "schema") ->
          find_fields_with_schema(%{kkey => value}, key, acc)
        Enum.member?([:category, :list], value["type"]) ->
          acc ++ [%{nested_key: to_indifferent_atom(key), name: to_indifferent_atom(kkey)}]
        true -> acc
      end
    end)
  end
end