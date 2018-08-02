defmodule Graveyard.ORM.Group do
  defmacro __using__(_) do
    quote do
      alias Graveyard.Support
      alias Graveyard.Errors
      alias Graveyard.Utils
      import Graveyard.ORM.Query
      import Graveyard.Maquiladoras.Group

      def group(filters \\ [], aggs \\ [], opts \\ %{})
      def group(filters, aggs, opts) when is_list(aggs) do
        default_opts = %{
          index: Support.index(), type: Support.type(), maquilate: true
        }
        opts = Map.merge(default_opts, opts)

        query = build_query(filters) |> Utils.to_keyword_list()
        aggregators = Graveyard.ORM.Group.build_aggs_query(aggs)

        group_query = Graveyard.ORM.Group.build_group_query(query, aggregators, opts)
          |> Tirexs.Query.create_resource

        if opts.maquilate do
          group_query |> maquilate
        else
          group_query
        end
      end

      def group(filters, aggs, opts) do
        raise Errors.BadArgumentError
      end
    end
  end

  alias Graveyard.Utils
  alias Graveyard.Support

  def build_aggs_query(aggs) do
    %{"aggs" => Graveyard.ORM.Group.agg_node_element(aggs)}
    |> Utils.to_keyword_list
  end

  def build_group_query(filters_query, aggs, opts) do
    %{
      index: opts.index,
      search: [size: 0] ++ filters_query ++ aggs
    }
  end

  def agg_node_element(aggs) do
    [head_agg | tail_aggs ] = aggs
    next_node_or_leaf = if Enum.empty?(tail_aggs) do
      # Leaf
      numeric_aggregations()
    else
      # Node
      agg_node_element(tail_aggs)
    end

    case head_agg["type"] do
      "simple" -> term_aggregation(head_agg, next_node_or_leaf)
      "range" -> range_aggregation(head_agg, next_node_or_leaf)
      "nested" -> nested_aggregation_object(head_agg, next_node_or_leaf)
    end
  end

  def numeric_aggregations() do
    averagable_fields = Support.numerical_fields()
    if Enum.count(averagable_fields) != 0 do
      averagable_fields |> Enum.reduce(%{}, fn(field, acc) -> 
        cond do
          String.starts_with?(field, "object") ->
            lst = String.split(field, ".")
            object_field = lst |> Enum.slice(1..(Enum.count(lst))) |> Enum.join(".")
            Map.put(acc, Utils.to_indifferent_atom(object_field), %{avg: %{field: object_field}})
          true ->
            Map.put(acc, Utils.to_indifferent_atom(field), %{avg: %{field: field}})
        end
      end)
    else
      %{document_count: %{cardinality: %{field: "_uid"}}}
    end
    |> Map.put(:document_count, %{cardinality: %{field: "_uid"}})
    |> Utils.to_keyword_list()
  end

  def term_aggregation(agg, next_node) do
    %{
      "aggregation" => %{
        "meta" => %{"field_name" => agg["key"], "type" => :simple},
        "terms" => %{"field" => agg["key"]},
        "aggs" => next_node
      }
    }
  end

  def range_aggregation(agg, next_node) do
    %{
      "aggregation" => %{
        "meta" => %{"field_name" => agg["key"], "type" => :range},
        "range" => %{
          "field" => agg["key"],
          "ranges" => build_range_agg(agg)
        },
        "aggs" => next_node
      }
    }
  end

  def nested_aggregation_object(agg, next_node) do
    %{
      "aggregation" => %{
        "meta" => %{"field_name" => agg["key"], "type" => :nested},
        "terms" => %{"field" => Enum.join(["__aux", agg["opts"]["path"], agg["key"]], ".")},
        "aggs" => next_node
      }
    }
  end

  def build_range_agg(agg) do
    %{"min" => min, "step" => step, "max" => max} = agg["opts"]
    ranges = [%{to: min}]
    ranges = ranges ++ generate_intermediate_ranges(min, step, max, [])
    ranges ++ [%{from: max}]
  end

  def generate_intermediate_ranges(min, step, max, acc \\ []) do
    mmax = min + step
    if mmax >= max do
      acc ++ [%{"from" => min, "to" => max}]
    else
      mmin = min + step
      acc ++ [%{"from" => min, "to" => mmax}] ++ generate_intermediate_ranges(mmin, step, max, acc)
    end 
  end
end