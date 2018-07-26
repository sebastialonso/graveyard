defmodule Graveyard.Utils.TirexsUris do
  import Tirexs.HTTP
  import Graveyard.Utils
  alias Graveyard.Support
  
  def count() do
    post("#{Support.index()}/#{Support.type()}/_count")
  end

  def count(query) when is_map(query) do
    post("#{Support.index()}/#{Support.type()}/_count", to_keyword_list(query))
  end

  def mappings() do
    get("#{Support.index()}/_mapping/#{Support.type()}")
  end

  def delete_mapping(index \\ Support.index) do
    delete(index)
  end

  def update(id, params) do
    put("#{Support.index()}/#{Support.type()}/#{id}", to_keyword_list(params))
  end
end