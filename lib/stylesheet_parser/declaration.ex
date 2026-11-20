defmodule StylesheetParser.Declaration do
  @moduledoc ~S"""
  A declaration, `name: value`, in a rule's block or a style attribute.

    * `name` - its property name, as written: in its case, and with any escapes.
    * `value` - its component values, without whitespace at either end, and without
      `!important`. In `unicode-range`, `U+0-7F` is one `{:urange, "U+0-7F"}`.
    * `important` - whether it ends with `!important`.
    * `line`, `column` - where its name starts.

  Only a custom property's value may have a `{}` block among other values; otherwise, a value
  with a `{}` block in it is only the block, and else the declaration is a nested rule instead.

      iex> {:ok, declaration} = StylesheetParser.parse_declaration("margin: 0 auto !important")
      iex> declaration
      %StylesheetParser.Declaration{
        name: "margin",
        value: [number: "0", whitespace: " ", ident: "auto"],
        important: true,
        line: 1,
        column: 1
      }
      iex> to_string(declaration)
      "margin: 0 auto !important;"

      iex> {:ok, declaration} = StylesheetParser.parse_declaration("background: url(a.png), linear-gradient(red, blue)")
      iex> declaration.value
      [
        {:url, "url(a.png)"},
        {:comma, ","},
        {:whitespace, " "},
        %StylesheetParser.Function{
          name: "linear-gradient",
          line: 1,
          column: 25,
          value: [ident: "red", comma: ",", whitespace: " ", ident: "blue"]
        }
      ]
  """
  defstruct [:name, :line, :column, value: [], important: false]

  defimpl String.Chars do
    alias StylesheetParser.Serialize

    def to_string(%{important: true} = declaration),
      do: "#{declaration.name}: #{Serialize.values(declaration.value)} !important;"

    def to_string(declaration), do: "#{declaration.name}: #{Serialize.values(declaration.value)};"
  end
end
