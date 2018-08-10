defmodule Graveyard.ORM.Insert do
  @moduledoc """
  Implements the `insert` function
  """
  defmacro __using__(_) do
    quote do
      @doc """
      Stores a map into ElasticsSearch. Returns {:ok, record} if success, {:error, error} otherwise
      """
      def insert(raw, opts \\ %{}) do
        cond do
          is_map(raw) ->
            Graveyard.ORM.Insert.do_save(raw, opts)
          is_list(raw) and Enum.map(raw, fn(x) -> is_map(x) end) ->
            Graveyard.ORM.Bulk.insert(raw, opts)
          true -> raise Errors.BadArgumentError, message: ":raw must be a map or list of maps."
        end
      end

    end
  end

  alias Graveyard.Support
  alias Graveyard.Record
  alias Graveyard.Mappings.Auxiliar
  alias Graveyard.ORM.Opts
  import Graveyard.Utils
  import Tirexs.HTTP

  def do_save(raw, opts) do
    opts = opts
      |> Opts.Insert.options
      
    ready_to_insert = prepare_object(raw)

    case post("#{opts.index}/#{opts.type}", ready_to_insert) do
      {:ok, 201, object} ->
        {:ok, Record.find(object._id, opts)}
      {:error, status, error} ->
        IO.inspect(status) 
        IO.inspect(error) 
        {:error, error}
    end
  end

  def prepare_object(raw) do
    if Enum.empty?(Graveyard.Mappings.Auxiliar.find_fields_with_schema()) do
      raw |> add_timestamps()
    else
      raw
        |> Map.put(:__aux, auxiliar_nested_fields(raw))
        |> add_timestamps()
    end
  end

  def auxiliar_nested_fields(raw_data, config \\ Support.mappings) do
    fields = Auxiliar.find_fields_with_schema(config)
    collected_values = Enum.reduce(fields, %{}, fn(field, acc) -> 
      traverse_element_looking_nested(raw_data, field, acc)
    end)
  end

  defp traverse_element_looking_nested(body, auxiliar_field, accumulator) do
    Enum.reduce(body, accumulator, fn({key, val}, acc) -> 
      cond do
        is_primitive_list(val) or is_boolean(val) or is_binary(val) or is_number(val) ->
          acc
        key == auxiliar_field.nested_key ->
          previous_value_for_nested_key = Map.get(acc, auxiliar_field.nested_key, %{})
          merged_value_for_nested_key = Map.merge(
            previous_value_for_nested_key, 
            %{ auxiliar_field.name => extract_all_values(val, auxiliar_field.name)}
          )          
          Map.put(acc, auxiliar_field.nested_key, merged_value_for_nested_key)
        is_map(val) ->
          traverse_element_looking_nested(val, auxiliar_field, acc)
        is_list_of_maps(val) ->
          Enum.reduce(val, acc, fn(mmap, inner_acc) -> 
            traverse_element_looking_nested(mmap, auxiliar_field, inner_acc)
          end)
        true ->
          acc   
      end
    end)
  end

  defp extract_all_values(lst, key) do
    Enum.map(lst, fn(x) -> 
      x[key]
    end) |> Enum.uniq
  end

  defp add_timestamps(document) do
    document
      |> Map.put(:created_at, now())
      |> Map.put(:updated_at, now())
  end
end