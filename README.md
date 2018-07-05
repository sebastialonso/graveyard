# Graveyard

A teeny-tiny ORM/library for managing ElasticSearch

## Installation

Just add

```elixir
def deps do
  [
    {:graveyard, "~> 0.1.0"}
  ]
end
```

to your `mix.exs`

# Configuration

Go to your `config/config.exs` and add the following configuration

~~~elixir
config :tirexs, :uri, "ELASTIC_HOST"

config :graveyard,
  index: "YOUR_ES_INDEX",
  type: "YOUR_ES_TYPE",
  mappings: CustomMappingsModule
~~~

The `uri` configuration is for Tirexs, the middleman between Graveyard and your ElasticSearch instance.

`index` and `type` are the names of you Elastic index and type respectively. `mappings` is the name of the module that will hold your mappings for Elastic. It must implemente the `get_mappings/2` function. A short example follows

~~~elixir
defmodule CustomMappingsModule do
  import Tirexs.Mapping

  def get_mappings(index_name, type_name) do
    index = [index: index_name, type: type_name]
    mappings do
      indexes "template", type: "keyword"
    end
  end
end
~~~

This uses the Tirexs `mappings` macro. For all available options see [this](https://github.com/Zatvobor/tirexs/blob/master/examples/mapping_with_settings.exs) example.


After all is set, go into iex and run `Graveyard.Mapping.create_settings_and_mappings()` and you'll be ready to go.


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/graveyard](https://hexdocs.pm/graveyard).

