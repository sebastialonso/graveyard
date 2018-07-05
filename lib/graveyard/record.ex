defmodule Graveyard.Record do
  @moduledoc """
  This the basic entity of graveyard.
  """
  use Graveyard.ORM.Find
  use Graveyard.ORM.Insert
end