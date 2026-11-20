defmodule StylesheetParser.Function do
  @moduledoc ~S"""
  A function among component values, such as `var(--gap, 1rem)`.

    * `name` - its name without the `(`, as written: in its case, and with any escapes.
    * `value` - its arguments' component values, commas and whitespace included.
    * `line`, `column` - where it starts.

  `url(a.png)` without quotes isn't a function but a `{:url, "url(a.png)"}` token; `url("a.png")`
  is a function.

      iex> {:ok, function} = StylesheetParser.parse_component_value("var(--gap, 1rem)")
      iex> {function.name, function.value}
      {"var", [ident: "--gap", comma: ",", whitespace: " ", dimension: ["1", "rem"]]}
      iex> to_string(function)
      "var(--gap, 1rem)"

      iex> StylesheetParser.parse_component_value("url(a.png)")
      {:ok, {:url, "url(a.png)"}}
      iex> {:ok, function} = StylesheetParser.parse_component_value(~S|url("a.png")|)
      iex> {function.name, function.value}
      {"url", [string: ~S("a.png")]}
  """
  defstruct [:name, :line, :column, value: []]

  defimpl String.Chars do
    def to_string(function),
      do: "#{function.name}(#{StylesheetParser.Serialize.values(function.value)})"
  end
end
