defmodule Graveyard.ORM.Validation do
  alias Graveyard.Support

  def build_validation_schema() do
    Support.mappings() 
    |> Enum.map(fn {key, value} -> 
      # Find type
      {:ok, type} = Map.fetch(value ,"type")
      # Get rid of everything that is not a constraint
      constraints = Map.delete(value, "type")
      # Build a keyword of all validations supported by that type
      { String.to_atom(key), [{ type, build_schema_for_type(type, constraints) }] }
    end)
  end

  @doc """
  Return all supported validations for integers
  """
  def build_schema_for_type(:integer, constraints) do
    [is: true] ++ Enum.map(constraints, fn {k, v} -> {String.to_atom(k), v} end)
  end

  @doc """
  Return all supported validations for texts
  """
  def build_schema_for_type(:text, constraints) do
    [is: true] ++ Enum.map(constraints, fn {k, v} -> {String.to_atom(k), v} end)
  end

  @doc """
  Return all supported validations for category
  """
  def build_schema_for_type(:category, constraints) do
    Enum.map(constraints, fn {k, v} -> {String.to_atom(k), v} end)
  end

  @doc """
  Return all supported validations for date
  """
  def build_schema_for_type(:date, constraints) do
    [is: true] ++ Enum.map(constraints, fn {k, v} -> {String.to_atom(k), v} end)
  end

  @doc """
  Return all supported validations for datetime
  """
  def build_schema_for_type(:datetime, constraints) do
    [is: true] ++ Enum.map(constraints, fn {k, v} -> {String.to_atom(k), v} end)
  end

  @doc """
  Return all supported validations for number
  """
  def build_schema_for_type(:number, constraints) do
    [is: true] ++ Enum.map(constraints, fn {k, v} -> {String.to_atom(k), v} end)
  end

  @doc """
  Groups al error information from Vex.results into a nice map
  """
  def group_errors(raw) do
    errors = raw
    |> Vex.results(build_validation_schema())
    |> Enum.filter(fn element ->
      Enum.count(Tuple.to_list(element)) == 4
    end)
    |> Enum.group_by(
      fn {:error, field, _type, _message} -> field end,
      fn {:error, _field, _type, message} -> message 
    end)

    case %{} == errors and Enum.count(errors) == 0 do
      true -> nil
      false -> errors
    end
  end

  def validate_with_vex(raw) do
    raw
    |> Vex.valid? build_validation_schema()
  end

  def validate(raw) do
     case validate_with_vex(raw) do
       true -> Map.put(Map.put(raw, :__valid__, true), :__errors__, nil)
       false -> Map.put(Map.put(raw, :__valid__, false), :__errors__, group_errors(raw))
     end
  end
end