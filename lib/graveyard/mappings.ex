defmodule Graveyard.Mappings do
  @moduledoc """
  Builds both mappings and settings into ElasticSearch
  """
  alias Graveyard.Support
  import Tirexs.Index.Settings

  @doc """
  Returns the mappings from the module indicated in `config.exs`
  """
  def get_mappings(index_name \\ Support.index(), type_name \\ Support.type()) do
    module = Support.mappings
    module.get_mappings(index_name, type_name)
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
    # if base == :error do
    #   raise "GraveyardError: ElasticSearch instance can't be reached"
    # end
  end
end
