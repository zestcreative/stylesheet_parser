defmodule StylesheetParser.AtRule do
  @moduledoc ~S"""
  An at-rule, such as `@import url(theme.css);` or `@media print { ... }`.

    * `name` - its name with its `@`, as written: in its case, and with any escapes.
    * `prelude` - the component values between its name and its block or `;`, without
      whitespace at either end.
    * `block` - nil for an at-rule that ends with `;`, else its declarations and rules, in order.
    * `line`, `column` - where it starts.
    * `top_level` - whether it's at the top level of a stylesheet.

  The parser doesn't know at-rules one by one: what a prelude means, and which declarations and
  rules a block may have, is up to you.

      iex> {:ok, import} = StylesheetParser.parse_rule("@import url(theme.css) screen;")
      iex> {import.name, import.prelude, import.block}
      {"@import", [url: "url(theme.css)", whitespace: " ", ident: "screen"], nil}

      iex> {:ok, media} = StylesheetParser.parse_rule("@media (width > 600px) { a { color: red } }")
      iex> Enum.map(media.prelude, &to_string/1)
      ["(width > 600px)"]
      iex> Enum.map(media.block, &to_string/1)
      ["a { color: red; }"]

      iex> {:ok, font_face} = StylesheetParser.parse_rule("@font-face { font-family: Inter; src: url(inter.woff2) }")
      iex> Enum.map(font_face.block, & &1.name)
      ["font-family", "src"]
  """
  defstruct [:name, :block, :line, :column, prelude: [], top_level: false]

  defimpl String.Chars do
    alias StylesheetParser.Serialize

    def to_string(%{name: name, prelude: [], block: block}), do: name <> Serialize.block(block)

    def to_string(%{name: name, prelude: prelude, block: block}),
      do: "#{name} #{Serialize.values(prelude)}#{Serialize.block(block)}"
  end
end
