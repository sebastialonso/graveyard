# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :tirexs,
  :uri, "http://127.0.0.1:9200"

config :graveyard,
  index: "graveyard_test_index",
  type: "graveyard_test_type",
  mappings: CustomMappingsForGraveyard