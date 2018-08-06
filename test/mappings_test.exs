defmodule Graveyard.MappingsTest do
  use ExUnit.Case

  alias Graveyard.Support
  alias Graveyard.Errors
  alias Graveyard.Mappings
  alias Graveyard.Support.Fixtures

  defmodule CustomMappings do
    import Tirexs.Mapping

    def get_mappings(index_name, type_name) do
      index = [index: index_name, type: type_name]
      mappings do
        indexes "name", type: "text"
        indexes "description", type: "text", analyzer: "nGram_analyzer"
      end
    end
  end

  defmodule WrongSignatureMappings do
    import Tirexs.Mapping

    def wrong_signature(index_name, type_name) do
      index = [index: index_name, type: type_name]
      mappings do
        indexes "name", type: "text"
        indexes "description", type: "text", analyzer: "nGram_analyzer"
      end
    end
  end

  @last_podcast_mappings Fixtures.simple_mappings()
  @advanced_last_podcast_mappings Fixtures.with_object_mappings()
  @oblist_last_podcast_mappings Fixtures.with_oblists_mappings()

  setup do
    Application.put_env(:tirexs, :uri, "http://localhost:9200")
    Application.put_env(:graveyard, :index, "test_graveyard_index")
    Tirexs.HTTP.delete(Support.index())
    :ok
  end

  describe "get_mappings/2" do
    setup do
      Application.put_env(:graveyard, :type, "test_graveyard_type")
      :ok
    end

    test "returns a mappings object with valid index key for module mappings" do
      Application.put_env(:graveyard, :mappings_module, CustomMappings)
      Application.put_env(:graveyard, :mappings, %{})

      actual = Mappings.get_mappings()
      properties = actual |> Keyword.fetch!(:mapping) |> Keyword.fetch!(:properties)
      assert Keyword.fetch!(actual, :index) == Application.get_env(:graveyard, :index)
      assert Keyword.fetch!(actual, :type)
      # Check automatic timestamps
      assert Keyword.has_key?(properties, :created_at)
      assert Keyword.has_key?(properties, :updated_at)
    end

    test "raise if custom mapping file has wrong function signature" do
      Application.put_env(:graveyard, :mappings_module, WrongSignatureMappings)
      Application.put_env(:graveyard, :mappings, nil)
      assert_raise Errors.ConfigModuleError, fn -> Mappings.get_mappings end
    end

    test "returns a valid mappings object for flat map mappings" do
      Application.put_env(:graveyard, :mappings_module, nil)
      Application.put_env(:graveyard, :mappings, @last_podcast_mappings)

      actual = Mappings.get_mappings()
      properties = actual 
        |> Keyword.fetch!(:mapping)
        |> Keyword.fetch!(:properties)

      assert Keyword.fetch!(actual, :index) == Application.get_env(:graveyard, :index)
      assert Keyword.fetch!(actual, :type) == Application.get_env(:graveyard, :type)
      assert Keyword.has_key?(properties, :created_at)
      assert Keyword.has_key?(properties, :updated_at)
    end

    test "returns a valid mappings object for map mappings with object" do
      Application.put_env(:graveyard, :mappings_module, nil)
      Application.put_env(:graveyard, :mappings, @advanced_last_podcast_mappings)

      actual = Mappings.get_mappings()
      properties = actual 
        |> Keyword.fetch!(:mapping)
        |> Keyword.fetch!(:properties)

      assert Keyword.fetch!(actual, :index) == Application.get_env(:graveyard, :index)
      assert Keyword.fetch!(actual, :type) == Application.get_env(:graveyard, :type)
      assert Keyword.has_key?(properties, :topic)
      topic_properties = Keyword.fetch!(properties, :topic) |> Keyword.fetch!(:properties)
      assert Keyword.has_key?(topic_properties, :name)
      assert Keyword.has_key?(topic_properties, :followers)
      assert Keyword.has_key?(topic_properties, :last_time_played)
    end

    test "returns a valid mappings object for map mappings with oblists" do
      Application.put_env(:graveyard, :mappings_module, nil)
      Application.put_env(:graveyard, :mappings, @oblist_last_podcast_mappings)

      actual = Mappings.get_mappings()
      properties = actual 
        |> Keyword.fetch!(:mapping)
        |> Keyword.fetch!(:properties)

      assert Keyword.fetch!(actual, :index) == Application.get_env(:graveyard, :index)
      assert Keyword.fetch!(actual, :type) == Application.get_env(:graveyard, :type)
      assert Keyword.has_key?(properties, :tags)
      tags_properties = Keyword.fetch!(properties, :tags) |> Keyword.fetch!(:properties)
      assert Keyword.has_key?(tags_properties, :name)
    end

    # Test with both module and map mappings
    test "raise if config file has nil for mappings and mappings_module" do
      Application.put_env(:graveyard, :mappings_module, nil)
      Application.put_env(:graveyard, :mappings, nil)
      assert_raise Errors.ConfigModuleError, fn -> Mappings.get_mappings end
    end
  end

  describe "create_settings_and_mappings/0" do
    setup do
      Application.put_env(:graveyard, :type, "test_graveyard_type")
      Application.put_env(:graveyard, :mappings_module, CustomMappings)
      :ok
    end

    test "returns :ok tuple from ElasticSearch" do
      {state, code, reason} = Mappings.create_settings_and_mappings()
      assert state == :ok
      assert reason = %{acknowledged: true}
    end

    test "raise if no ElasticSearch is found" do
      Application.put_env(:tirexs, :uri, "http://nowheretobefound")
      assert_raise Errors.ElasticSearchInstanceError, fn -> Mappings.create_settings_and_mappings() end
    end
  end
end