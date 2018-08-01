defmodule Graveyard.Maquiladoras.Group do
  def maquilate(results) do
    case results do
      {:ok, 200, %{aggregations: aggs}} ->
        maquilate_recursively(aggs) 
          |> List.flatten()
      {:error, status, reason} ->
        {:error, reason}
    end
  end

  defp maquilate_recursively(aggs, parent_bucket \\ %{}) do
    do_we_recurse = Map.has_key?(aggs, :aggregation) and Map.has_key?(aggs[:aggregation], :buckets)
    case do_we_recurse do
      false -> Map.put(parent_bucket, :data, process_leaf(aggs))
      true ->
        Enum.map(aggs[:aggregation][:buckets], fn(bucket) -> 
          parent_bucket = if Map.has_key?(parent_bucket, :source) do
            new_source = Map.get(parent_bucket, :source) ++ [%{field_name: aggs[:aggregation][:meta][:field_name], value: bucket[:key]}]
            Map.put(parent_bucket, :source, new_source)
          else
            Map.put(parent_bucket, :source, [%{field_name: aggs[:aggregation][:meta][:field_name], value: bucket[:key]}])
          end 
          maquilate_recursively(bucket, parent_bucket)
        end)
    end
  end

  defp process_leaf(leaf) do
    leaf
      |> Map.drop([:from, :to, :key, :doc_count, :key_as_string])
      |> clean_leaf_values
  end

  defp clean_leaf_values(leaf) do
    Enum.map(leaf, fn({key, val}) -> 
      if is_map(val) do
        {key, Map.get(val, :value)}
      end 
    end)
    |> Enum.into(%{})
  end
end