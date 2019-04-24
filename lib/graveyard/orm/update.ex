defmodule Graveyard.ORM.Update do
  defmacro __using__(_opts) do
    quote do
      def update(id, params) do
        Graveyard.ORM.Update.do_update(id, params) 
      end
    end
  end

  alias Graveyard.{Support, Record}
  alias Graveyard.ORM.Opts
  import Graveyard.Utils.TirexsUris
  import Graveyard.Utils
  import Graveyard.ORM.Validation

  def do_update(id, params, opts \\ %{}) do
    opts = opts
      |> Opts.Update.options

    case Record.find(id) do
      nil -> nil
      record ->
        updated = record
          |> Map.drop([:id])
          |> Map.merge(to_indifferent_map(params))

        if opts.validate_before_update do
          validated = validate(updated)
          case validated.__valid__ do
            true ->
              validated = Map.drop(validated, [:__valid__, :__errors__])
              attempt_to_update(id, validated, opts)
            false ->
              {:error, :validation_failure, validated.__errors__}
          end
        else
          attempt_to_update(id, updated, opts)
        end
    end
  end

  defp attempt_to_update(id, input, opts) do
    input = Map.put(input, :updated_at, now())
    case update(id, input) do
      {:ok, 200, %{_id: id}} ->
        {:ok, Record.find(id)}
      {:error, status, reason} ->
        IO.inspect status
        IO.inspect reason
        {:error, reason}
    end
  end
end
