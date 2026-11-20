defmodule StylesheetParser.QualifiedRule do
  @moduledoc ~S"""
  A style rule, such as `.card > h2 { margin: 0 }`.

    * `prelude` - its selector list, as `StylesheetParser.SimpleSelector`,
      `StylesheetParser.CompoundSelector` and `StylesheetParser.ComplexSelector` structs. In
      `@keyframes`, the keyframe selectors' component values instead, such as `50%`.
    * `block` - its `StylesheetParser.Declaration`s and nested rules, in order.
    * `line`, `column` - where it starts.
    * `top_level` - whether it's at the top level of a stylesheet.

  A rule whose selectors don't parse is dropped, with a `StylesheetParser.ParseError`.

      iex> {:ok, rule} = StylesheetParser.parse_rule(".card > h2, .note { margin: 0; &:hover { color: red } }")
      iex> Enum.map(rule.prelude, &to_string/1)
      [".card > h2", ".note"]
      iex> Enum.map(rule.block, &to_string/1)
      ["margin: 0;", "&:hover { color: red; }"]
      iex> to_string(rule)
      ".card > h2, .note { margin: 0; &:hover { color: red; } }"

  A keyframe's prelude is its component values:

      iex> {:ok, keyframes} = StylesheetParser.parse_rule("@keyframes spin { from { opacity: 0 } 50% { opacity: 1 } }")
      iex> Enum.map(keyframes.block, & &1.prelude)
      [[ident: "from"], [percentage: "50"]]
  """
  defstruct [:line, :column, block: [], prelude: [], top_level: false]

  defimpl String.Chars do
    alias StylesheetParser.Serialize

    def to_string(%{prelude: prelude, block: block}),
      do: Serialize.selectors(prelude) <> Serialize.block(block)
  end
end
