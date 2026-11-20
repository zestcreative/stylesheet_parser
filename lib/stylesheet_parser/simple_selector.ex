defmodule StylesheetParser.SimpleSelector do
  @moduledoc ~S"""
  A selector of one part, such as `.card` or `:hover`.

    * `type` - what it selects by:
      * `:type` - an element's name, as `h2`, `svg|circle` or `svg|*`.
      * `:universal` - `*`.
      * `:id` - `#main`.
      * `:class` - `.card`.
      * `:attribute` - `[href^="https:" i]`.
      * `:pseudo_class` - `:hover`, or a functional one, as `:not(.a)`.
      * `:nesting` - `&`, the rule it's nested in.
    * `value` - its text, as written. A functional pseudo-class's value is a
      `StylesheetParser.PseudoClass` when its arguments parse (`:is()`, `:where()`, `:not()` and
      the `:nth-*()` ones), else a `StylesheetParser.Function`.

  The same `{type, value}` pairs are the parts of a `StylesheetParser.CompoundSelector`.

      iex> {:ok, rule} = StylesheetParser.parse_rule(~S|.card, #main, [href^="https:" i], * { }|)
      iex> rule.prelude
      [
        %StylesheetParser.SimpleSelector{type: :class, value: ".card"},
        %StylesheetParser.SimpleSelector{type: :id, value: "#main"},
        %StylesheetParser.SimpleSelector{type: :attribute, value: ~S|[href^="https:" i]|},
        %StylesheetParser.SimpleSelector{type: :universal, value: "*"}
      ]
  """
  defstruct [:type, :value]

  defimpl String.Chars do
    def to_string(selector), do: StylesheetParser.Serialize.selector(selector)
  end
end
