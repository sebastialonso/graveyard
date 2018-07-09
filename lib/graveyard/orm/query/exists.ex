defmodule Graveyard.ORM.Query.Exists do
  def exists_query filter do
    %{exists: %{field: filter["field"]}}
  end
end