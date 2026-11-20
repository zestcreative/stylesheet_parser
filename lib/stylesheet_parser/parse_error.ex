defmodule StylesheetParser.ParseError do
  @moduledoc ~S"""
  Malformed input, and where it is.

    * `message` - what's wrong, one of:
      * `"unclosed {"`, `"unclosed ["`, `"unclosed ("`, `"unclosed name("` - a block or function
        that the input ends in. It closes at the end, and the error is where it opens.
      * `"expected : after name"` - a declaration without its colon, dropped.
      * `"expected a declaration"` - something where a declaration belongs that isn't one or a
        nested rule, such as the IE hack `*zoom: 1`, dropped.
      * `"invalid selector"` - a rule whose selectors don't parse, dropped.
      * `"expected { after the selector"` - a rule that the input ends in before its block,
        dropped.
      * `"expected a rule"`, `"expected one rule"`, `"expected a component value"`,
        `"expected one component value"` - from the functions that parse one thing, given none
        or more than one.
      * `"unexpected input"` - input that isn't UTF-8.
    * `line`, `column` - where it is, columns counting bytes from 1, or nil at the end of the
      input.

  `Exception.message/1` is `"line:column: message"`.

      iex> {:ok, stylesheet} = StylesheetParser.parse_stylesheet("a {\n  color red;\n}")
      iex> [error] = stylesheet.errors
      iex> error
      %StylesheetParser.ParseError{message: "expected : after color", line: 2, column: 3}
      iex> Exception.message(error)
      "2:3: expected : after color"

      iex> StylesheetParser.parse_declaration("12px")
      {:error, %StylesheetParser.ParseError{message: "expected a declaration", line: 1, column: 1}}
  """
  defexception [:message, :line, :column]

  @impl true
  def message(%{message: message, line: nil}), do: message

  def message(%{message: message, line: line, column: column}),
    do: "#{line}:#{column}: #{message}"
end
