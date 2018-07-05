defmodule Graveyard.Errors do
  defmodule WrongConfigModuleError do
    defexception message: "Missing function"

    def full_message(error) do
      "Supplied module has no get_mappings/2 function"
    end
  end

  defmodule NoElasticSearchInstance do
    defexception message: "No ElasticSearch found"
  end
end
