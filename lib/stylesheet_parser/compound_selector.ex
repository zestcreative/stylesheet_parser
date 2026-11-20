defmodule StylesheetParser.CompoundSelector do
  @moduledoc ~S"""
  Selectors of one element together, such as `a.external:hover::after`.

    * `value` - its parts in order, each a `{type, value}` pair as a
      `StylesheetParser.SimpleSelector`'s. A pseudo-element and the pseudo-classes after it are a
      list of their own: `[pseudo_element: "::after"]`, or `[pseudo_element: "::part(label)",
      pseudo_class: ":hover"]`, its value a `StylesheetParser.Function` when it has arguments.

      iex> {:ok, %{prelude: [selector]}} = StylesheetParser.parse_rule("a.external:hover::after { }")
      iex> selector.value
      [{:type, "a"}, {:class, ".external"}, {:pseudo_class, ":hover"}, [pseudo_element: "::after"]]
      iex> to_string(selector)
      "a.external:hover::after"
  """
  defstruct value: []

  defimpl String.Chars do
    def to_string(selector), do: StylesheetParser.Serialize.selector(selector)
  end
end
