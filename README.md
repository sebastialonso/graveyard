# Graveyard

[![Hex.pm](https://img.shields.io/badge/hex-0.6.3-blue.svg)](https://hex.pm/packages/graveyard) [![Tests](https://img.shields.io/badge/test-47%20passed%2C%200%20failed-green.svg)](https://github.com/sebastialonso/graveyard/tree/master/test)

A teeny-tiny ORM/library for managing ElasticSearch

## Installation

Just add

```elixir
def deps do
  [
    {:graveyard, "~> 0.6.3"}
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
  type: "YOUR_ES_TYPE".
  date_format: ~r/^(-?(?:[1-9][0-9]*)?[0-9]{4})-(1[0-2]|0[1-9])-(3[01]|0[1-9]|[12][0-9])$/,
  datetime_format: ~r/^(-?(?:[1-9][0-9]*)?[0-9]{4})-(1[0-2]|0[1-9])-(3[01]|0[1-9]|[12][0-9])T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\\.[0-9]+)?(Z)?$/,
  validate_before_insert: false,
  validate_before_update: false

~~~

* The `uri` configuration is for Tirexs, the middleman between Graveyard and your ElasticSearch instance.

* `index` and `type` are the names of you Elastic index and type respectively.

* `date_format` and `datetime_format`: The format in which you want to validate and store your date objets in ElasticSearch

* `validate_before_insert`: Pass true if you want to validate your inputs objects before being stored into ElasticSearch. Defaults to `false`.

* `validate_before_update`: Pass true if you want to validate your inputs objects before being updated into ElasticSearch. Defaults to `false`.

## Mappings

There's two ways to supply mappings to Graveyard. Passing an object that follows the Graveyard type system (recommended) or passing a module.

For the first way, pass a `mappings` key to the configuration with the mappings map as the value.

For the module way, pass a `mappings_module` key with the module names as the value, and follow the instructions below. 

`mappings_module` is the name of the module that will hold your mappings for Elastic. It must implement the `get_mappings/2` function. A short example follows


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

----

After your mapping alternative is set, go into iex and run `Graveyard.Mapping.create_settings_and_mappings()` and you'll be ready to go.


## Validations

Validations are now possible for the `insert` and `update` functions.
Validations are avaliable for the following types (possible validation listed)

* `integer`: Regular integer. Automatically checks for type correctnes. Also `greater_than`, `less_than`, `equal_to`, `greater_than_or_equal_to`, `less_than_or_equal_to`.

* `number`: Non-integers (floats). Automatically checks for type correctnes. Also `greater_than`, `less_than`, `equal_to`, `greater_than_or_equal_to`, `less_than_or_equal_to`.

* `text`: Searchable strings. Automatically checks for type correctnes. Also `format` (pass a regex object)

* `date`: String representation of a date. Automatically checks for type. Default type is ISO 8601: 'YYYY-MM-dd' (example: 2019-04-25). You can change the date format in the master configuration

* `date`: String representation of a datetime. Automatically checks for type. Default type is ISO 8601: 'YYYY-MM-ddTHH:mm:ss' (example: 2019-04-25T20:00:00). You can change the datetime format in the master configuration

* `category`: For values within a list of values. No automatic type checking, since categories don't have intrinsic type. `within` (pass a list of allowed values) and `within_module` (pass the name of a module, having an `options/0` funtion that returns a list of values)

More validations, and support for the rest of the type system will follow hopefully soon.

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/graveyard](https://hexdocs.pm/graveyard).

