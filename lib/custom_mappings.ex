defmodule CustomMappingsForGraveyard do
  import Tirexs.Mapping

  def get_mappings(index_name, type_name) do
    index = [index: index_name, type: type_name]
    mappings do
      indexes "title", type: "text", analyzer: "nGram_analyzer"
      indexes "content", type: "keyword"
    end
  end
end