defmodule Graveyard.Mappings do
  @moduledoc """
  Builds both mappings and settings into ElasticSearch
  """
  alias Graveyard.Support
  alias Graveyard.Errors
  alias Graveyard.Utils
  alias Graveyard.Mappings.Basic
  alias Graveyard.Mappings.Builder
  alias Graveyard.Utils.TirexsUris
  import Tirexs.Index.Settings

  @doc """
  Returns the mappings object processed from the configured mappings module or the configured map
  """
  def get_mappings(index_name \\ Support.index(), type_name \\ Support.type()) do
    mappings_from_config = cond do
      is_nil(Support.mappings_module) and is_nil(Support.mappings) ->
        raise Errors.ConfigModuleError, "Any of :mappings or :mappings_module must be set in config"
      !is_nil(Support.mappings_module) ->
        Basic.get_mappings(index_name, type_name)
      !is_nil(Support.mappings) or Enum.count(Support.mappings) < 1 ->
        Builder.get_mappings(index_name, type_name)
      true -> 
        raise Errors.ConfigModuleError, "Any of :mappings or :mappings_module must be set in config"
    end

    properties_enhanced = mappings_from_config 
      |> Keyword.fetch!(:mapping) 
      |> Keyword.fetch!(:properties)
      |> Keyword.merge(Builder.timestamps())
      |> Keyword.merge(add_custom_keywords())

    Keyword.take(mappings_from_config, [:index, :type]) ++ [mapping: [properties: properties_enhanced]]
  end

  @doc """
  Returns the predefined settings
  """
  def get_settings(index \\ Support.index()) do
    index = [index: index]
    settings do
      analysis do
        analyzer "nGram_analyzer", [type: "custom", tokenizer: "edge_ngram_tokenizer", filter: ["lowercase", "asciifolding"]]
        tokenizer "edge_ngram_tokenizer", [type: "edgeNGram", min_gram: 1, max_gram: 20, token_chars: ["letter", "digit"]]
        filter "nGram_filter", [type: "edgeNGram", min_gram: 1, max_gram: 20, token_chars: ["letter", "digit"]]
      end
    end
  end

  @doc """
  Merges mappings and settings information and creates index and type in the ElasticSearch instance
  """
  def create_settings_and_mappings(opts \\ %{index: Support.index(), type: Support.type()}) do
    base = get_settings(opts.index) ++ get_mappings(opts.index, opts.type)
      |> Keyword.delete_first(:index)
      |> Tirexs.Mapping.create_resource

    case base do
      :error -> raise Errors.ElasticSearchInstanceError
       _ -> base 
    end
  end

  @doc """
  To be used when the mappings have changed. It ppdates the current mappings with the new one, 
  maintaining all records within the index.
  """
  def apply_mappings_change() do
    temporal_index = [source: [index: Support.index(), type: Support.type()], dest: [index: "tmp", type: Support.type()]]
    original_index = [source: [index: "tmp", type: Support.type()], dest: [index: Support.index(), type: Support.type()]]
    
    IO.inspect "1) Building temporal index..."
    IO.inspect create_settings_and_mappings(%{index: "tmp", type: Support.type()})    

    IO.inspect "2) Reindexing to tmp..."
    IO.inspect Tirexs.HTTP.post("/_reindex?refresh", temporal_index)

    IO.inspect "3) Deleting original index..."
    IO.inspect TirexsUris.delete_mapping()

    IO.inspect "4) Buliding new version of original index..."
    IO.inspect create_settings_and_mappings()
    
    IO.inspect "5) Reindexing to original index..."
    IO.inspect Tirexs.HTTP.post("/_reindex?refresh", original_index)

    IO.inspect "6) Deleting temporal index..."
    IO.inspect TirexsUris.delete_mapping("tmp")
  end

  defp add_custom_keywords() do
    []
  end
end
