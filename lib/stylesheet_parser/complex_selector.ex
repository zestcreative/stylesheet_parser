defmodule StylesheetParser.ComplexSelector do
  @moduledoc ~S"""
  Compound selectors joined by combinators, such as `.card > h2 span`.

    * `value` - its first compound selector, then a `[combinator, compound_selector]` list for
      each one after it. Each compound selector is a `StylesheetParser.SimpleSelector` or a
      `StylesheetParser.CompoundSelector`, and each combinator one of:
      * `{:descendant_combinator, " "}`
      * `{:child_combinator, ">"}`
      * `{:sibling_combinator, "+"}`
      * `{:subsequent_combinator, "~"}`
      * `{:column_combinator, "||"}`

      iex> {:ok, %{prelude: [selector]}} = StylesheetParser.parse_rule(".card > h2 span { }")
      iex> selector.value
      [
        %StylesheetParser.SimpleSelector{type: :class, value: ".card"},
        [{:child_combinator, ">"}, %StylesheetParser.SimpleSelector{type: :type, value: "h2"}],
        [{:descendant_combinator, " "}, %StylesheetParser.SimpleSelector{type: :type, value: "span"}]
      ]
      iex> to_string(selector)
      ".card > h2 span"

  A relative selector, as a nested rule's may be, starts with its combinator:

      iex> {:ok, %{block: [%{prelude: [selector]}]}} = StylesheetParser.parse_rule(".card { > h2 { } }")
      iex> selector.value
      [[{:child_combinator, ">"}, %StylesheetParser.SimpleSelector{type: :type, value: "h2"}]]
      iex> to_string(selector)
      "> h2"
  """
  defstruct value: []

  defimpl String.Chars do
    def to_string(selector), do: StylesheetParser.Serialize.selector(selector)
  end
end
