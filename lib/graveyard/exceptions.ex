defmodule Graveyard.Errors do
  defmodule ConfigModuleError do
    defexception message: "Missing function"

    def full_message(error) do
      "Supplied module has no get_mappings/2 function"
    end
  end

  defmodule ElasticSearchInstanceError do
    defexception message: "No ElasticSearch found"
  end
end
