defmodule StylesheetParser.Syntax.Tokenizer do
  @moduledoc ~S"""
  The [tokenizer](https://www.w3.org/TR/css-syntax-3/#tokenization) of CSS Syntax Level 3, over
  preprocessed input (`StylesheetParser.tokenize/1` turns `\r\n`, `\r` and `\f` into `\n` and NUL into
  U+FFFD).

  Each token is `{type, value, [line: line, column: column]}`, where it starts, columns counting
  bytes from 1. Its value is its source text: a string keeps its quotes, and escapes stay escaped
  (`StylesheetParser.unescape/1` decodes them). Comments are dropped, an unclosed one running to
  the end.

  | Type | Value | Such as |
  | --- | --- | --- |
  | `:ident` | the name | `color`, `--gap`, `\31 0` |
  | `:function` | the name and its `(`; a `StylesheetParser.Function` among component values | `var(` |
  | `:at_keyword` | the name and its `@` | `@media` |
  | `:hash` | the name and its `#` | `#main`, `#f00` |
  | `:string` | the string, with its quotes | `"a.png"` |
  | `:bad_string` | a string with a newline in it, up to the newline | `"a` |
  | `:url` | the whole `url()` without quotes, or with escapes in `url` | `url(a.png)`, `u\72l(a.png)` |
  | `:bad_url` | a `url()` with whitespace, a quote or a `(` inside | `url(a b)` |
  | `:number` | the number | `12`, `-0.5`, `1e3` |
  | `:percentage` | the number, without its `%` | `50` for `50%` |
  | `:dimension` | `[number, unit]` | `["1", "px"]` |
  | `:whitespace` | the whitespace | `" "`, `"\n  "` |
  | `:delim` | any other code point | `>`, `.`, `!` |
  | `:colon`, `:semicolon`, `:comma` | `:`, `;`, `,` | |
  | `:lparen`, `:rparen`, `:lbracket`, `:rbracket`, `:lcurly`, `:rcurly` | the bracket; a `StylesheetParser.SimpleBlock` among component values | `(` |
  | `:cdo`, `:cdc` | `<!--`, `-->` | |
  | `:urange` | a unicode range, only in a `unicode-range` declaration's value | `U+0-7F` |

      iex> StylesheetParser.tokenize("a { margin: 1px }")
      {:ok,
       [
         {:ident, "a", [line: 1, column: 1]},
         {:whitespace, " ", [line: 1, column: 2]},
         {:lcurly, "{", [line: 1, column: 3]},
         {:whitespace, " ", [line: 1, column: 4]},
         {:ident, "margin", [line: 1, column: 5]},
         {:colon, ":", [line: 1, column: 11]},
         {:whitespace, " ", [line: 1, column: 12]},
         {:dimension, ["1", "px"], [line: 1, column: 13]},
         {:whitespace, " ", [line: 1, column: 16]},
         {:rcurly, "}", [line: 1, column: 17]}
       ]}
  """

  # The template for `tokenizer.ex`, so NimbleParsec isn't needed at runtime. After changing it:
  #
  #     mix nimble_parsec.compile lib/stylesheet_parser/syntax/tokenizer.ex.exs

  @doc false
  # Each token as `{type, value, metadata}`, like Elixir AST: `[line: l, column: c]` where it
  # starts, columns counting bytes from 1.
  def at([{[{[], {line, line_offset}}], offset}, {type, value}]),
    do: {type, value, [line: line, column: offset - line_offset + 1]}

  # parsec:StylesheetParser.Syntax.Tokenizer
  import NimbleParsec

  # 4.2. Definitions
  newline = string("\n")
  whitespace = choice([string(" "), string("\t"), newline])
  hex_digit = ascii_string([?0..?9, ?a..?f, ?A..?F], 1)
  digits = ascii_string([?0..?9], min: 1)
  non_ascii = utf8_string([0x80..0x10FFFF], 1)
  ident_start = choice([ascii_string([?a..?z, ?A..?Z, ?_], 1), non_ascii])
  ident_code_point = choice([ascii_string([?a..?z, ?A..?Z, ?0..?9, ?_, ?-], 1), non_ascii])

  # 4.3.7. Consume an escaped code point: up to six hex digits and one whitespace after them, or
  # any code point but a newline (4.3.8. a valid escape), or the end of the input.
  escape =
    string("\\")
    |> choice([
      times(hex_digit, min: 1, max: 6) |> optional(whitespace),
      utf8_string([{:not, ?\n}], 1),
      eos()
    ])

  # 4.3.11. Consume an ident sequence, where 4.3.9. would start one.
  ident =
    choice([
      string("-") |> choice([ident_start, string("-"), escape]),
      ident_start,
      escape
    ])
    |> repeat(choice([ident_code_point, escape]))
    |> reduce({List, :to_string, []})

  # 4.3.2. Consume comments
  comment =
    string("/*")
    |> repeat(lookahead_not(string("*/")) |> utf8_string([], 1))
    |> choice([string("*/"), eos()])

  whitespace_token = times(whitespace, min: 1) |> reduce({List, :to_string, []})

  # 4.3.5. Consume a string token: to its closing quote or the end of the input; a newline first
  # makes it a bad string, without the newline.
  string_body = fn quote ->
    repeat(
      choice([
        utf8_string([{:not, quote}, {:not, ?\\}, {:not, ?\n}], min: 1),
        string("\\") |> concat(newline),
        escape
      ])
    )
  end

  string_token =
    choice(
      for quote <- [?", ?'] do
        string(<<quote>>) |> concat(string_body.(quote)) |> choice([string(<<quote>>), eos()])
      end
    )
    |> reduce({List, :to_string, []})

  # Tried after `string_token`, so its body stopped at a newline.
  bad_string_token =
    choice(for quote <- [?", ?'], do: string(<<quote>>) |> concat(string_body.(quote)))
    |> reduce({List, :to_string, []})

  hash_token =
    string("#")
    |> times(choice([ident_code_point, escape]), min: 1)
    |> reduce({List, :to_string, []})

  # 4.3.12. Consume a number
  number =
    optional(ascii_string([?+, ?-], 1))
    |> choice([digits |> string(".") |> concat(digits), digits, string(".") |> concat(digits)])
    |> optional(
      ascii_string([?e, ?E], 1)
      |> optional(ascii_string([?+, ?-], 1))
      |> concat(digits)
    )
    |> reduce({List, :to_string, []})

  # 4.3.3. Consume a numeric token
  dimension_token = concat(number, ident)
  percentage_token = number |> ignore(string("%"))

  # 4.3.4. Consume an ident-like token: an ident that is `url` once its escapes are decoded, and
  # `(`, is a url token unless a quote follows it, and then it's a function token like any other.
  # Each letter of `url` is in either case, `\` and the letter, or `\` and its hex digits, after
  # zeros up to six digits and with one whitespace after them, as `u\72l(` or `\75 rl(`.
  url_letter = fn letter ->
    cases = [letter, letter - 32]

    hex =
      Enum.flat_map(cases, fn code_point ->
        digits = Integer.to_string(code_point, 16)
        Enum.uniq([String.downcase(digits), String.upcase(digits)])
      end)

    choice([
      ascii_string(cases, 1),
      string("\\") |> ascii_string(cases, 1),
      string("\\")
      |> times(string("0"), max: 4)
      |> choice(Enum.map(hex, &string/1))
      |> optional(whitespace)
    ])
  end

  url_open =
    url_letter.(?u)
    |> concat(url_letter.(?r))
    |> concat(url_letter.(?l))
    |> string("(")
    |> repeat(whitespace)

  # 4.3.6. Consume a url token
  url_token =
    url_open
    |> repeat(
      choice([
        utf8_string(
          [
            {:not, ?"},
            {:not, ?'},
            {:not, ?(},
            {:not, ?)},
            {:not, ?\\},
            {:not, ?\s},
            {:not, ?\t},
            {:not, ?\n},
            {:not, 0..8},
            {:not, 11},
            {:not, 14..31},
            {:not, 127}
          ],
          min: 1
        ),
        escape
      ])
    )
    |> repeat(whitespace)
    |> choice([string(")"), eos()])
    |> reduce({List, :to_string, []})

  # 4.3.14. Consume the remnants of a bad url
  bad_url_token =
    url_open
    |> lookahead_not(ascii_string([?", ?'], 1))
    |> repeat(choice([escape, utf8_string([{:not, ?)}, {:not, ?\\}], min: 1), string("\\")]))
    |> choice([string(")"), eos()])
    |> reduce({List, :to_string, []})

  function_token = ident |> string("(") |> reduce({List, :to_string, []})
  at_keyword_token = string("@") |> concat(ident) |> reduce({List, :to_string, []})

  # 4.3.1. Consume a token, in the order the spec looks at the next code points.
  token =
    choice([
      whitespace_token |> unwrap_and_tag(:whitespace),
      string_token |> unwrap_and_tag(:string),
      bad_string_token |> unwrap_and_tag(:bad_string),
      hash_token |> unwrap_and_tag(:hash),
      dimension_token |> tag(:dimension),
      percentage_token |> unwrap_and_tag(:percentage),
      number |> unwrap_and_tag(:number),
      string("-->") |> unwrap_and_tag(:cdc),
      url_token |> unwrap_and_tag(:url),
      bad_url_token |> unwrap_and_tag(:bad_url),
      function_token |> unwrap_and_tag(:function),
      ident |> unwrap_and_tag(:ident),
      string("<!--") |> unwrap_and_tag(:cdo),
      at_keyword_token |> unwrap_and_tag(:at_keyword),
      string("(") |> unwrap_and_tag(:lparen),
      string(")") |> unwrap_and_tag(:rparen),
      string("[") |> unwrap_and_tag(:lbracket),
      string("]") |> unwrap_and_tag(:rbracket),
      string("{") |> unwrap_and_tag(:lcurly),
      string("}") |> unwrap_and_tag(:rcurly),
      string(",") |> unwrap_and_tag(:comma),
      string(":") |> unwrap_and_tag(:colon),
      string(";") |> unwrap_and_tag(:semicolon),
      utf8_string([], 1) |> unwrap_and_tag(:delim)
    ])

  defparsec(
    :consume,
    repeat(
      choice([
        ignore(comment),
        empty() |> line() |> byte_offset() |> concat(token) |> reduce({__MODULE__, :at, []})
      ])
    )
  )

  # parsec:StylesheetParser.Syntax.Tokenizer
end
