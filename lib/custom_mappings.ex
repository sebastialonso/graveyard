defmodule CustomMappingsForGraveyard do
  import Tirexs.Mapping

  def get_mappings(index_name, type_name) do
    index = [index: index_name, type: type_name]
    mappings do
      indexes "title", type: "text", analyzer: "nGram_analyzer"
      indexes "template", type: "keyword"
      indexes "slides", type: "nested"
      indexes "created_at", type: "date", format: "dd/MM/yyyy HH:mm:ss"
      indexes "updated_at", type: "date", format: "dd/MM/yyyy HH:mm:ss"
    end
  end
end