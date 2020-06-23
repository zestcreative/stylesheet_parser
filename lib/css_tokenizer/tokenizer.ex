defmodule CssTokenizer.Tokenizer do
  @moduledoc """
  https://www.w3.org/TR/css-syntax-3
  """

  import NimbleParsec

  newline = string("\n")
  tab = string("\t")
  space = string(" ")

  comment_token =
    string("/*")
    |> repeat(lookahead_not(string("*/")) |> utf8_char([]))
    |> string("*/")
    |> reduce({List, :to_string, []})

  defparsec :comment_token, comment_token

  hex_digit = ascii_char([?a..?f, ?A..?F, ?0..?9])

  whitespace = choice([space, tab, newline])

  whitespace_token =
    times(whitespace, min: 1)
    |> reduce({List, :to_string, []})

  defparsec :whitespace_token, whitespace_token

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

  defparsec :ident_token, ident_token

  function_token =
    ident_token
    |> concat(string("("))

  defparsec :function_token, function_token

  at_keyword_token =
    string("@")
    |> concat(ident_token)
    |> reduce({List, :to_string, []})

  defparsec :at_keyword_token, at_keyword_token

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

  defparsec :hash_token, hash_token

  string_token =
    choice([
      string("\"")
      |> repeat(
        choice([
          utf8_char([{:not, ?"}, {:not, ?\\}, {:not, ?\n}]),
          escape,
          concat(string("\\"), newline)
        ])
      )
      |> string("\"")
      |> reduce({List, :to_string, []}),
      string("'")
      |> repeat(
        choice([
          utf8_char([{:not, ?'}, {:not, ?\\}, {:not, ?\n}]),
          escape,
          concat(string("\\"), newline)
        ])
      )
      |> string("\'")
      |> reduce({List, :to_string, []})
    ])

  defparsec :string_token, string_token

  scientific_notation =
    choice([
      string("e"),
      string("E")
    ])
    |> choice([
      empty(),
      string("+"),
      string("-")
    ])
    |> times(ascii_char([?0..?9]), min: 1)

  url_token =
    string("(")
    |> concat(maybe_whitespace |> ignore)
    |> repeat(
      choice([
        utf8_char([
          {:not, ?'},
          {:not, ?(},
          {:not, ?)},
          {:not, ?\\},
          {:not, ?/},
          {:not, 0..32},
          {:not, 127},
        ]),
        escape
      ])
    )
    |> concat(maybe_whitespace |> ignore)
    |> string(")")
    |> reduce({List, :to_string, []})

  defparsec :url_token, url_token

  number_token =
    choice([
      empty(),
      string("+"),
      string("-")
    ])
    |> choice([
      times(ascii_char([?0..?9]), min: 1) |> string(".") |> times(ascii_char([?0..?9]), min: 1),
      times(ascii_char([?0..?9]), min: 1),
      string(".") |> times(ascii_char([?0..?9]), min: 1)
    ])
    |> optional(scientific_notation)
    |> reduce({List, :to_string, []})

  defparsec :number_token, number_token

  dimension_token = concat(number_token, ident_token)
  defparsec :dimension_token, dimension_token

  percentage_token = concat(number_token, string("%") |> ignore())
  defparsec :percentage_token, percentage_token

  cdo_token = string("<!--")
  defparsec :cdo_token, cdo_token

  cdc_token = string("-->")
  defparsec :cdc_token, cdc_token

  numeric_token =
    choice([
      dimension_token,
      percentage_token,
      number_token
    ])
  defparsec :numeric_token, numeric_token

  ident_like_token =
    choice([
      ident_token,
      function_token,
      url_token
    ])
  defparsec :ident_like_token, ident_like_token

  lparen_token = string("(")
  rparen_token = string(")")
  lbracket_token = string("[")
  rbracket_token = string("]")
  lcurly_token = string("{")
  rcurly_token = string("}")
  comma_token = string(",")
  colon_token = string(":")
  semicolon_token = string(";")

  defparsec :consume,
    comment_token
    |> ignore()
    |> optional()
    |> choice([
      whitespace_token |> unwrap_and_tag(:whitespace),
      string_token |> unwrap_and_tag(:string),
      hash_token |> unwrap_and_tag(:hash),
      lparen_token |> unwrap_and_tag(:lparen),
      rparen_token |> unwrap_and_tag(:rparen),
      dimension_token |> tag(:dimension),
      percentage_token |> unwrap_and_tag(:percentage),
      number_token |> unwrap_and_tag(:number),
      comma_token |> unwrap_and_tag(:comma),
      cdc_token |> unwrap_and_tag(:cdc),
      ident_token |> unwrap_and_tag(:ident),
      function_token |> unwrap_and_tag(:function),
      url_token |> unwrap_and_tag(:url),
      cdo_token |> unwrap_and_tag(:cdo),
      at_keyword_token |> unwrap_and_tag(:at_keyword),
      colon_token |> unwrap_and_tag(:colon),
      semicolon_token |> unwrap_and_tag(:semicolon),
      lbracket_token |> unwrap_and_tag(:lbracket),
      rbracket_token |> unwrap_and_tag(:rbracket),
      lcurly_token |> unwrap_and_tag(:lcurly),
      rcurly_token |> unwrap_and_tag(:rcurly),
      utf8_char([]) |> unwrap_and_tag(:delim)
    ])
    |> repeat()
end
