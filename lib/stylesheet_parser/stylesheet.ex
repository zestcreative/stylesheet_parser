defmodule StylesheetParser.Stylesheet do
  @moduledoc ~S"""
  A parsed stylesheet, from `StylesheetParser.parse_stylesheet/1`.

    * `rules` - its `StylesheetParser.QualifiedRule`s and `StylesheetParser.AtRule`s, in order.
    * `errors` - a `StylesheetParser.ParseError` for each thing it dropped or recovered from, in
      the order they are in the input.

  `to_string/1` serializes its rules, one a line.

      iex> {:ok, stylesheet} = StylesheetParser.parse_stylesheet("a { color: red } b { color: blue; oops }")
      iex> Enum.map(stylesheet.rules, &to_string/1)
      ["a { color: red; }", "b { color: blue; }"]
      iex> Enum.map(stylesheet.errors, &Exception.message/1)
      ["1:35: expected : after oops"]
      iex> to_string(stylesheet)
      "a { color: red; }\nb { color: blue; }"
  """
  defstruct rules: [], errors: []

  defimpl String.Chars do
    def to_string(%{rules: rules}), do: Enum.map_join(rules, "\n", &Kernel.to_string/1)
  end
end
