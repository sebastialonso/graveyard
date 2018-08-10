defmodule Graveyard.Utils.Macros do
  defmacro is_maplist(lst) do
    quote do
      is_list(unquote(lst)) and Enum.all?(unquote(lst), fn(x) -> is_map(x) end)
    end
  end
end