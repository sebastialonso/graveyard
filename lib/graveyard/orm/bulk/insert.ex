defmodule Graveyard.ORM.Bulk.Insert do
  alias Graveyard.Errors
  alias Graveyard.ORM.Opts
  alias Graveyard.ORM.Insert
  import Graveyard.Utils
  import Tirexs.Bulk

  def insert(raw, opts \\ %{}) do
    try do
      cond do
        is_list(raw) and Enum.map(raw, fn(x) -> is_map(x) end) ->
          opts = opts |> Opts.Insert.options
          raw = raw
            |> Enum.map(&Insert.prepare_object/1)
            |> do_bulk_save(opts)
            |> ids_from_created
        true -> raise Errors.BadArgumentError, message: ":raw must be a list of maps."
      end
    rescue
      e in Protocol.UndefinedError -> raise Errors.BadArgumentError, message: ":raw must be a list of maps."
    end
  end

  def do_bulk_save(rows, opts) do
    payload = bulk do
      index [ index: opts.index, type: opts.type ], Enum.map(rows, &to_keyword_list/1)
    end
    Tirexs.bump!(payload)._bulk({ [refresh: true] })
  end

  def ids_from_created({:ok, 200, %{items: items}} = results) do
    items
    |> Enum.map(fn result ->
      result
      |> Map.get(:index)
      |> Map.get(:_id)
    end)
  end
end