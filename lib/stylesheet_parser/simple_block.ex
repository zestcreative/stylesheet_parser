defmodule StylesheetParser.SimpleBlock do
  @moduledoc ~S"""
  A block among component values: in `()`, such as a media feature `(width > 600px)`; in `[]`,
  such as an attribute selector's; or in `{}`.

    * `terminator` - the token that ends it: `:rparen`, `:rbracket` or `:rcurly`.
    * `value` - the component values inside it.
    * `line`, `column` - where it starts.

  A rule's `{}` block is parsed into its declarations and rules, so a `{}` `SimpleBlock` is only
  where a value has one, such as a custom property's.

      iex> {:ok, block} = StylesheetParser.parse_component_value("(width > 600px)")
      iex> {block.terminator, block.value}
      {:rparen, [ident: "width", whitespace: " ", delim: ">", whitespace: " ", dimension: ["600", "px"]]}
      iex> to_string(block)
      "(width > 600px)"
  """
  defstruct [:terminator, :line, :column, value: []]

  defimpl String.Chars do
    def to_string(%{terminator: terminator, value: value}) do
      {open, close} = %{rcurly: {"{", "}"}, rbracket: {"[", "]"}, rparen: {"(", ")"}}[terminator]
      open <> StylesheetParser.Serialize.values(value) <> close
    end
  end
end
