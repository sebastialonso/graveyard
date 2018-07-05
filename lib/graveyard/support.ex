defmodule Graveyard.Support do
  @moduledoc """
  Access configuration values
  """

  @doc """
  Returns the configured index name
  """
  def index do
    Application.get_env(:graveyard, :index)
  end

  @doc """
  Returns the configured type name
  """
  def type do
    Application.get_env(:graveyard, :type)
  end

  def mappings_module do
    Application.get_env(:graveyard, :mappings_module)
  end

  def mappings do
    Application.get_env(:graveyard, :mappings)
  end
end