defmodule Graveyard.Support do
  @moduledoc """
  Access configuration values
  """

  @doc """
  Returns the configured ElasticSearch index name
  """
  def index do
    Application.get_env(:graveyard, :index)
  end

  @doc """
  Returns the configured ElasticSearch type name
  """
  def type do
    Application.get_env(:graveyard, :type)
  end

  @doc """
  Returns the configured mappings module
  """
  def mappings_module do
    Application.get_env(:graveyard, :mappings_module)
  end

  @doc """
  Returns the configured mappings map
  """
  def mappings do
    Application.get_env(:graveyard, :mappings)
  end

  @doc """
  Returns an array of all fields of numeric types recursively. All numeric types fields (:integer, :number)
  will be returned, even they are nested inside an :object or :oblist schema. 
  This is useful for functions such as group.
  String names returned instead of atoms. For fields inside nested schemas, the parent key is appended to the name (i.e. "topic.followers").
  """
  def numerical_fields(config \\ Graveyard.Support.mappings, parent \\ "") do
    config
      |> Enum.reduce([], fn({key, val}, acc) -> 
        cond do
          Enum.member?([:integer, :number], val["type"]) ->
            if parent == "" do
              acc ++ [key]
            else
              acc ++ [parent <> "." <> key]
            end
          Enum.member?([:object, :oblist], val["type"]) ->
            case val["type"] do
              :object ->
                if parent == "" do
                  acc ++ [numerical_fields(val["schema"], "object." <> key)]
                else
                  acc ++ [numerical_fields(val["schema"], parent <> "." <> key)]
                end
              :oblist ->
                if parent == "" do
                  acc ++ [numerical_fields(val["schema"], "nested." <> key)]
                else
                  acc ++ [numerical_fields(val["schema"], parent <> "." <> key)]
                end
            end
          true -> acc
        end
      end) |> List.flatten
  end

  @doc """
  Returns the configured regex to validate format of date strings
  """
  def date_format() do
    Application.get_env(:graveyard, :date_format)
  end

  @doc """
  Returns the configured regex to validate format of datetime strings
  """
  def datetime_format() do
    Application.get_env(:graveyard, :datetime_format)
  end
end