defmodule StylesheetParser.PseudoClass do
  @moduledoc ~S"""
  A functional pseudo-class whose arguments parse: `:is()`, `:where()`, `:not()`, and the
  `:nth-*()` ones.

    * `name` - its name without the `:` or `(`, as written.
    * `selectors` - the selectors of `:is()`, `:where()` and `:not()`, and of `:nth-child()` and
      `:nth-last-child()` after `of`.
    * `an_b` - the An+B of the `:nth-*()` ones, `{a, b}`: `2n+1` and `odd` are `{2, 1}`, `even`
      is `{2, 0}`, and `3` is `{0, 3}`. Nil for the others.

  `:is()` and `:where()` drop the selectors that don't parse, as their forgiving selector lists
  do; for `:not()`, or `:nth-child()` after `of`, they make the whole selector invalid. None may
  have a pseudo-element.

      iex> {:ok, %{prelude: [%{value: [{:type, "li"}, {:pseudo_class, nth_child}]}]}} =
      ...>   StylesheetParser.parse_rule("li:nth-child(odd of .item) { }")
      iex> nth_child
      %StylesheetParser.PseudoClass{
        name: "nth-child",
        an_b: {2, 1},
        selectors: [%StylesheetParser.SimpleSelector{type: :class, value: ".item"}]
      }
      iex> to_string(nth_child)
      "nth-child(2n+1 of .item)"

      iex> {:ok, %{prelude: [%{value: is}]}} = StylesheetParser.parse_rule(":is(h1, ::before, h2) { }")
      iex> to_string(is)
      "is(h1, h2)"
  """
  defstruct [:name, :an_b, selectors: []]

  defimpl String.Chars do
    def to_string(pseudo_class), do: StylesheetParser.Serialize.pseudo_class(pseudo_class)
  end
end
