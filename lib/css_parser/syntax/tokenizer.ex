defmodule CssParser.Syntax.Tokenizer do
  @moduledoc """
  https://www.w3.org/TR/css-syntax-3

  Not currently tokenized: `An+B` microsyntax with idents
  """

  import NimbleParsec

  newline =
    choice([
      string("\r\n") |> replace("\n"),
      string("\f") |> replace("\n"),
      string("\n")
    ])

  tab = string("\t")
  space = string(" ")

  comment_token =
    string("/*")
    |> repeat(lookahead_not(string("*/")) |> utf8_string([], 1))
    |> string("*/")
    |> reduce({List, :to_string, []})

  defparsec(:comment_token, comment_token)

  hex_digit = utf8_string([?a..?f, ?A..?F, ?0..?9], 1)

  whitespace = choice([space, tab, newline])

  whitespace_token =
    times(whitespace, min: 1)
    |> reduce({List, :to_string, []})

  defparsec(:whitespace_token, whitespace_token)

  maybe_whitespace = repeat(whitespace_token)

  non_ascii = ascii_char([{:not, 0..255}])

  escape =
    string("\\")
    |> concat(
      choice([
        times(hex_digit, min: 1, max: 6) |> optional(whitespace),
        lookahead_not(choice([newline, hex_digit]))
      ])
    )

  ident_token =
    choice([
      string("--"),
      string("-")
      |> optional()
      |> choice([
        choice([
          ascii_char([?a..?z, ?A..?Z]),
          string("_"),
          non_ascii
        ]),
        escape
      ])
    ])
    |> repeat(
      choice([
        choice([
          ascii_char([?a..?z, ?A..?Z, ?0..?9]),
          string("_"),
          string("-"),
          non_ascii
        ]),
        escape
      ])
    )
    |> reduce({List, :to_string, []})

  defparsec(:ident_token, ident_token)

  function_token =
    ident_token
    |> concat(string("("))
    |> reduce({List, :to_string, []})

  defparsec(:function_token, function_token)

  at_keyword_token =
    string("@")
    |> concat(ident_token)
    |> reduce({List, :to_string, []})

  defparsec(:at_keyword_token, at_keyword_token)

  hash_token =
    string("#")
    |> times(
      choice([
        choice([
          ascii_char([?a..?z, ?A..?Z, ?0..?9]),
          string("_"),
          string("-"),
          non_ascii
        ]),
        escape
      ]),
      min: 1
    )
    |> reduce({List, :to_string, []})

  defparsec(:hash_token, hash_token)

  string_token =
    choice([
      string("\"")
      |> repeat(
        choice([
          utf8_string([{:not, ?"}, {:not, ?\\}, {:not, ?\n}], 1),
          escape,
          concat(string("\\"), newline)
        ])
      )
      |> string("\"")
      |> reduce({List, :to_string, []}),
      string("'")
      |> repeat(
        choice([
          utf8_string([{:not, ?'}, {:not, ?\\}, {:not, ?\n}], 1),
          escape,
          concat(string("\\"), newline)
        ])
      )
      |> string("\'")
      |> reduce({List, :to_string, []})
    ])

  defparsec(:string_token, string_token)

  scientific_notation =
    choice([
      string("e"),
      string("E")
    ])
    |> optional(choice([string("+"), string("-")]))
    |> times(ascii_char([?0..?9]), min: 1)

  url_token =
    string("url(")
    |> concat(maybe_whitespace |> ignore)
    |> repeat(
      choice([
        escape,
        utf8_string(
          [
            {:not, ?"},
            {:not, ?'},
            {:not, ?(},
            {:not, ?)},
            {:not, ?\\},
            {:not, 0..8},
            {:not, 11},
            {:not, 14..31},
            {:not, 127}
          ],
          1
        )
      ])
    )
    |> concat(maybe_whitespace |> ignore)
    |> string(")")
    |> reduce({List, :to_string, []})

  defparsec(:url_token, url_token)

  bad_url_token =
    string("url(")
    |> concat(maybe_whitespace |> ignore)
    |> repeat(
      choice([
        lookahead_not(escape),
        utf8_string(
          [
            ?",
            ?',
            ?(,
            ?),
            ?\\,
            0..8,
            11,
            14..31,
            127
          ],
          1
        )
      ])
    )
    |> concat(maybe_whitespace |> ignore)
    |> string(")")
    |> reduce({List, :to_string, []})

  defparsec(:bad_url_token, bad_url_token)

  integer_token =
    choice([
      string("+"),
      string("-")
    ])
    |> optional()
    |> times(ascii_char([?0..?9]), min: 1)

  signed_integer_token =
    choice([string("-"), string("+")])
    |> times(ascii_char([?0..?9]), min: 1)

  signless_integer_token = times(ascii_char([?0..?9]), min: 1)

  number_token =
    choice([
      string("+"),
      string("-")
    ])
    |> optional()
    |> choice([
      times(ascii_char([?0..?9]), min: 1) |> string(".") |> times(ascii_char([?0..?9]), min: 1),
      times(ascii_char([?0..?9]), min: 1),
      string(".") |> times(ascii_char([?0..?9]), min: 1)
    ])
    |> optional(scientific_notation)
    |> reduce({List, :to_string, []})

  dimension_token = concat(number_token, ident_token)
  defparsec(:dimension_token, dimension_token)

  ndimension_token = integer_token |> utf8_string([?n, ?N], 1)
  ndashdimension_token = ndimension_token |> string("-")
  ndashdigit_dimension_token = ndashdimension_token |> utf8_string([?0..?9], min: 1)

  a_n_b_token =
    choice([
      utf8_string([?o, ?O], 1) |> utf8_string([?d, ?D], 1) |> utf8_string([?d, ?D], 1),
      utf8_string([?e, ?E], 1)
      |> utf8_string([?v, ?V], 1)
      |> utf8_string([?e, ?E], 1)
      |> utf8_string([?n, ?N], 1),
      concat(ndimension_token, signed_integer_token),
      concat(repeat(string("+")) |> utf8_string([?n, ?N], 1), signed_integer_token),
      concat(string("-") |> utf8_string([?n, ?N], 1), signed_integer_token),
      concat(ndashdimension_token, signless_integer_token),
      concat(
        repeat(string("+")) |> utf8_string([?n, ?N], 1) |> string("-"),
        signless_integer_token
      ),
      concat(string("-") |> utf8_string([?n, ?N], 1) |> string("-"), signless_integer_token),
      concat(ndimension_token |> choice([string("-"), string("+")]), signless_integer_token),
      concat(
        repeat(string("+")) |> utf8_string([?n, ?N], 1) |> choice([string("-"), string("+")]),
        signless_integer_token
      ),
      concat(
        string("-") |> utf8_string([?n, ?N], 1) |> choice([string("-"), string("+")]),
        signless_integer_token
      ),
      # integer_token, # this is catching too much
      ndimension_token,
      # made it match at least 1 to catch less
      times(string("+"), min: 1) |> utf8_string([?n, ?N], 1),
      string("-") |> utf8_string([?n, ?N], 1),
      ndashdigit_dimension_token
    ])
    |> reduce({List, :to_string, []})

  defparsec(:number_token, number_token)

  percentage_token = concat(number_token, string("%") |> ignore())
  defparsec(:percentage_token, percentage_token)

  cdo_token = string("<!--")
  defparsec(:cdo_token, cdo_token)

  cdc_token = string("-->")
  defparsec(:cdc_token, cdc_token)

  numeric_token =
    choice([
      dimension_token,
      percentage_token,
      number_token
    ])

  defparsec(:numeric_token, numeric_token)

  ident_like_token =
    choice([
      ident_token,
      function_token,
      url_token
    ])

  defparsec(:ident_like_token, ident_like_token)

  urange_token =
    choice([
      string("U"),
      string("u")
    ])
    |> string("+")
    |> times(choice([hex_digit, string("?")]), min: 1, max: 6)
    |> string("-")
    |> times(hex_digit, min: 1, max: 6)
    |> reduce({List, :to_string, []})

  defparsec(:urange, urange_token)

  lparen_token = string("(")
  rparen_token = string(")")
  lbracket_token = string("[")
  rbracket_token = string("]")
  lcurly_token = string("{")
  rcurly_token = string("}")
  comma_token = string(",")
  colon_token = string(":")
  semicolon_token = string(";")

  @doc false
  # Each token as `{type, value, metadata}`, like Elixir AST: `[line: l, column: c]` where it
  # starts, columns counting bytes from 1.
  def at(rest, [{type, value}], context, {line, line_offset}, offset),
    do: {rest, [{type, value, [line: line, column: offset - line_offset + 1]}], context}

  token =
    choice([
      whitespace_token |> unwrap_and_tag(:whitespace),
      urange_token |> unwrap_and_tag(:urange),
      hash_token |> unwrap_and_tag(:hash),
      url_token |> unwrap_and_tag(:url),
      bad_url_token |> unwrap_and_tag(:bad_url),
      function_token |> unwrap_and_tag(:function),
      a_n_b_token |> unwrap_and_tag(:anb),
      cdc_token |> unwrap_and_tag(:cdc),
      cdo_token |> unwrap_and_tag(:cdo),
      dimension_token |> tag(:dimension),
      percentage_token |> unwrap_and_tag(:percentage),
      number_token |> unwrap_and_tag(:number),
      lparen_token |> unwrap_and_tag(:lparen),
      rparen_token |> unwrap_and_tag(:rparen),
      comma_token |> unwrap_and_tag(:comma),
      ident_token |> unwrap_and_tag(:ident),
      at_keyword_token |> unwrap_and_tag(:at_keyword),
      colon_token |> unwrap_and_tag(:colon),
      semicolon_token |> unwrap_and_tag(:semicolon),
      lbracket_token |> unwrap_and_tag(:lbracket),
      rbracket_token |> unwrap_and_tag(:rbracket),
      lcurly_token |> unwrap_and_tag(:lcurly),
      rcurly_token |> unwrap_and_tag(:rcurly),
      string_token |> unwrap_and_tag(:string),
      utf8_string([], 1) |> unwrap_and_tag(:delim)
    ])

  defparsec(
    :consume,
    repeat(choice([ignore(comment_token), pre_traverse(token, {__MODULE__, :at, []})]))
  )
end
