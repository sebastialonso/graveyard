defmodule Graveyard.Record do
  @moduledoc """
  This the basic entity of graveyard.
  """
  use Graveyard.ORM.Find
  use Graveyard.ORM.Insert
  use Graveyard.ORM.Search
  use Graveyard.ORM.Count
end