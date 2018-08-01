defmodule Graveyard.Mappings.AuxiliarTest do
  use ExUnit.Case

  alias Graveyard.Support.Fixtures
  alias Graveyard.Mappings.Auxiliar

  describe "build_auxiliar_mappings/0" do
    setup do
      :ok
    end

    test "returns the correct auxiliar object for mapping with a single :oblist field" do
      expected = [__aux: [properties: [tags: [properties: [name: [type: "keyword"]], type: "object"]], type: "object"]]
      actual = Auxiliar.build_auxiliar_mappings(Fixtures.with_oblists_mappings())
      assert expected == actual
    end

    test "returns the correct auxiliar object for mapping with a nested :oblist field" do
      expected = [
        __aux: [properties: [
          examples: [properties: [name: [type: "keyword"], tags: [type: "keyword"]], type: "object"],
          sets: [properties: [symbol: [type: "keyword"]], type: "object"]
        ], type: "object"]
      ]
      actual = Auxiliar.build_auxiliar_mappings(Fixtures.with_nested_oblists_mappings())
      assert expected == actual
    end
  end
end