defmodule Graveyard.Support do
  @moduledoc """
  Access configuration values
  """

  @elastic_index Application.get_env(:graveyard, :index)
  @elastic_type Application.get_env(:graveyard, :type)
  @mappings Application.get_env(:graveyard, :mappings)

  @doc """
  Returns the configured index name
  """
  def index do
    @elastic_index
  end

  @doc """
  Returns the configured type name
  """
  def type do
    @elastic_type
  end

  def mappings do
    @mappings
  end
end