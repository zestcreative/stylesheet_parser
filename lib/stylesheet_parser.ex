defmodule StylesheetParser do
  @moduledoc ~S"""
  A [CSS Syntax Level 3](https://www.w3.org/TR/css-syntax-3/) tokenizer and parser, with
  [CSS Nesting](https://www.w3.org/TR/css-nesting-1/) and a
  [Selectors Level 4](https://www.w3.org/TR/selectors-4/) selector parser.

      iex> {:ok, stylesheet} = StylesheetParser.parse_stylesheet("a { color: red } .card > b:hover { margin: 0 }")
      iex> to_string(stylesheet)
      "a { color: red; }\n.card > b:hover { margin: 0; }"

  ## Parsing

  `parse_stylesheet/1` parses a stylesheet. The others parse a part of one, as the spec's
  [parser entry points](https://www.w3.org/TR/css-syntax-3/#parser-entry-points) do:

  | Function | Parses | Returns |
  | --- | --- | --- |
  | `parse_stylesheet/1` | a stylesheet | `{:ok, %StylesheetParser.Stylesheet{}}` |
  | `parse_rules/1` | rules, such as an `@media` block's | `{:ok, rules, errors}` |
  | `parse_rule/1` | one rule | `{:ok, rule}` |
  | `parse_declarations/1` | a style attribute: declarations and nested rules | `{:ok, contents, errors}` |
  | `parse_declaration/1` | one declaration | `{:ok, %StylesheetParser.Declaration{}}` |
  | `parse_component_values/1` | component values, such as a media query list | `{:ok, values}` |
  | `parse_component_value/1` | one component value | `{:ok, value}` |
  | `tokenize/1` | tokens, as `StylesheetParser.Syntax.Tokenizer` has them | `{:ok, tokens}` |

  Those that parse one thing are `{:error, %StylesheetParser.ParseError{}}` given none or more
  than one, and all of them given input that isn't UTF-8.

      iex> {:ok, declarations, []} = StylesheetParser.parse_declarations("color: red; margin: 0 auto")
      iex> Enum.map(declarations, &to_string/1)
      ["color: red;", "margin: 0 auto;"]

      iex> StylesheetParser.parse_rule("a { } b { }")
      {:error, %StylesheetParser.ParseError{message: "expected one rule", line: 1, column: 7}}

  ## Rules, declarations and component values

  A stylesheet's rules are `StylesheetParser.QualifiedRule`s (style rules) and
  `StylesheetParser.AtRule`s, and a rule's block is its `StylesheetParser.Declaration`s and
  nested rules. A declaration's value and an at-rule's prelude are component values:
  `StylesheetParser.Function`s, `StylesheetParser.SimpleBlock`s, and the other tokens as
  `{type, value}`, each value its source text.

      iex> {:ok, declaration} = StylesheetParser.parse_declaration("border: 1px solid var(--line, #ccc)")
      iex> declaration.value
      [
        {:dimension, ["1", "px"]},
        {:whitespace, " "},
        {:ident, "solid"},
        {:whitespace, " "},
        %StylesheetParser.Function{
          name: "var",
          line: 1,
          column: 19,
          value: [ident: "--line", comma: ",", whitespace: " ", hash: "#ccc"]
        }
      ]

  Rules, declarations, functions and blocks have the `line` and `column` where they start.

  ## Malformed CSS

  Malformed CSS is dropped, as the spec recovers from it, and each `StylesheetParser.ParseError`
  kept:

      iex> {:ok, stylesheet} = StylesheetParser.parse_stylesheet("a { color red; margin: 0 }")
      iex> to_string(stylesheet)
      "a { margin: 0; }"
      iex> Enum.map(stylesheet.errors, &Exception.message/1)
      ["1:5: expected : after color"]

  ## Walking and sanitizing

  `prewalk/2`, `postwalk/2` and `traverse/4` walk the rules and declarations, to replace or drop
  them. They don't walk values, so a sanitizer goes through a declaration's value, and an
  at-rule's prelude, itself. This one replaces each URL with a placeholder: a `url()` token or a
  bad url, and a `url("...")` function, its name compared `unescape/1`d and downcased as
  `U\52L(...)` is one too, wherever they are among the values:

      iex> defmodule NoURLs do
      ...>   alias StylesheetParser.{AtRule, Declaration, Function, SimpleBlock}
      ...>
      ...>   @placeholder {:url, "url(about:invalid)"}
      ...>
      ...>   def sanitize(stylesheet) do
      ...>     StylesheetParser.prewalk(stylesheet, fn
      ...>       %Declaration{value: value} = declaration -> %{declaration | value: values(value)}
      ...>       %AtRule{prelude: prelude} = rule -> %{rule | prelude: values(prelude)}
      ...>       rule -> rule
      ...>     end)
      ...>   end
      ...>
      ...>   defp values(values), do: Enum.map(values, &value/1)
      ...>
      ...>   defp value({type, _text}) when type in [:url, :bad_url], do: @placeholder
      ...>
      ...>   defp value(%Function{name: name, value: value} = function) do
      ...>     if url?(name), do: @placeholder, else: %{function | value: values(value)}
      ...>   end
      ...>
      ...>   defp value(%SimpleBlock{value: value} = block), do: %{block | value: values(value)}
      ...>   defp value(token), do: token
      ...>
      ...>   defp url?(name), do: name |> StylesheetParser.unescape() |> String.downcase() == "url"
      ...> end
      iex> {:ok, stylesheet} =
      ...>   StylesheetParser.parse_stylesheet(
      ...>     ~S|@import url(theme.css); .hero { background: image-set(url(hero.png) 1x, url("hero@2x.png") 2x), red } .icon { mask: U\52L(icon.svg) }|
      ...>   )
      iex> stylesheet |> NoURLs.sanitize() |> to_string()
      "@import url(about:invalid);\n.hero { background: image-set(url(about:invalid) 1x, url(about:invalid) 2x), red; }\n.icon { mask: url(about:invalid); }"

  A URL can be a plain string too, as in `@import "theme.css"` or `image-set("hero.png" 1x)`:
  to catch those, replace strings where URLs go as well, or allow only the at-rules and
  functions known to be safe.

  ## Serializing

  `to_string/1` serializes what they return. Comments are dropped (a `/**/` stays only where two
  tokens would otherwise run together) and whitespace normalized, so the output parses to the
  same rules again.
  """

  alias __MODULE__.Syntax.{Tokenizer, Parser}
  alias __MODULE__.{AtRule, QualifiedRule, Stylesheet}

  @doc """
  Intended to be the normal parser entry point, for parsing stylesheets.
  """
  def parse_stylesheet(css) when is_binary(css) do
    with {:ok, tokens} <- tokenize(css) do
      Parser.parse_stylesheet(tokens)
    end
  end

  @doc """
  Intended for the content of at-rules such as @media. It differs from `parse_stylesheet/1` in the
  handling of <CDO-token> and <CDC-token>. Returns `{:ok, rules, errors}`, with the
  `StylesheetParser.ParseError`s for what it dropped or recovered from.
  """
  def parse_rules(css) when is_binary(css) do
    with {:ok, tokens} <- tokenize(css) do
      Parser.parse_rules(tokens)
    end
  end

  @doc """
  Intended for use by the CSSStyleSheet#insertRule method, and similar functions which might exist,
  which parse text into a single rule.
  """
  def parse_rule(css) when is_binary(css) do
    with {:ok, tokens} <- tokenize(css) do
      Parser.parse_rule(tokens)
    end
  end

  @doc """
  Used in `@supports` conditions. [CSS3-CONDITIONAL](https://www.w3.org/TR/css3-conditional/)
  """
  def parse_declaration(css) when is_binary(css) do
    with {:ok, tokens} <- tokenize(css) do
      Parser.parse_declaration(tokens)
    end
  end

  @doc """
  Used for the contents of a style attribute, which parses text into the contents of a single style
  rule: its declarations, at-rules and nested rules. Returns `{:ok, contents, errors}`, with the
  `StylesheetParser.ParseError`s for what it dropped or recovered from.
  """
  def parse_declarations(css) when is_binary(css) do
    with {:ok, tokens} <- tokenize(css) do
      Parser.parse_declarations(tokens)
    end
  end

  @doc """
  Used for things that need to consume a single value, like the parsing rules for `attr()`.
  """
  def parse_component_value(css) when is_binary(css) do
    with {:ok, tokens} <- tokenize(css) do
      Parser.parse_component_value(tokens)
    end
  end

  @doc """
  Used for the contents of presentational attributes, which parse text into a single declaration’s
  value, or for parsing a stand-alone selector [SELECT](https://www.w3.org/TR/selectors-3/) or list
  of Media Queries [MEDIAQ](https://www.w3.org/TR/mediaqueries-4/), as in Selectors API or the media
  HTML attribute.
  """
  def parse_component_values(css) when is_binary(css) do
    with {:ok, tokens} <- tokenize(css) do
      Parser.parse_component_values(tokens)
    end
  end

  @doc """
  The tokens of `css`, each `{type, value, metadata}` like Elixir AST, its metadata `[line: l, column: c]`
  where it starts (columns count bytes from 1). Comments are dropped.

  The input is [preprocessed](https://www.w3.org/TR/css-syntax-3/#input-preprocessing) first:
  `\\r\\n`, `\\r` and `\\f` become `\\n`, and NUL becomes U+FFFD.
  """
  def tokenize(css) do
    css = css |> String.replace(["\r\n", "\r", "\f"], "\n") |> String.replace(<<0>>, "�")

    case Tokenizer.consume(css) do
      {:ok, tokens, "", _, _, _} ->
        {:ok, tokens}

      {:ok, _tokens, _rest, _, {line, line_offset}, offset} ->
        {:error,
         %StylesheetParser.ParseError{
           message: "unexpected input",
           line: line,
           column: offset - line_offset + 1
         }}
    end
  end

  @doc ~S"""
  The text of a name, string or url with its escapes decoded, as the spec's token values are:
  `\` and up to six hex digits, and one whitespace after them, is the code point they number
  (U+FFFD for 0, a surrogate or more than U+10FFFF); `\` and a newline is nothing, as in a string
  that goes on to the next line; `\` and any other code point is that code point; and `\` at
  the end is U+FFFD.

  Names keep their escapes as written, and a browser reads `b\65havior` as `behavior`, so decode
  names before comparing them.

      iex> StylesheetParser.unescape(~S"b\65havior")
      "behavior"
      iex> StylesheetParser.unescape(~S"@\69 mport")
      "@import"
      iex> StylesheetParser.unescape(~S"a\:b\31 0")
      "a:b10"
  """
  def unescape(text) when is_binary(text), do: text |> unescape([]) |> IO.iodata_to_binary()

  defp unescape("", decoded), do: decoded
  defp unescape("\\", decoded), do: [decoded, "\uFFFD"]
  defp unescape("\\\n" <> rest, decoded), do: unescape(rest, decoded)

  defp unescape("\\" <> rest, decoded) do
    case hex_digits(rest, "") do
      {"", <<code_point::utf8, rest::binary>>} ->
        unescape(rest, [decoded, <<code_point::utf8>>])

      {hex, rest} ->
        code_point = String.to_integer(hex, 16)
        unescape(skip_one_whitespace(rest), [decoded, escaped_code_point(code_point)])
    end
  end

  defp unescape(<<code_point::utf8, rest::binary>>, decoded),
    do: unescape(rest, [decoded, <<code_point::utf8>>])

  defp hex_digits(<<digit, rest::binary>>, hex)
       when byte_size(hex) < 6 and (digit in ?0..?9 or digit in ?a..?f or digit in ?A..?F),
       do: hex_digits(rest, hex <> <<digit>>)

  defp hex_digits(rest, hex), do: {hex, rest}

  defp skip_one_whitespace(<<whitespace, rest::binary>>) when whitespace in [?\s, ?\t, ?\n],
    do: rest

  defp skip_one_whitespace(rest), do: rest

  defp escaped_code_point(code_point)
       when code_point == 0 or code_point in 0xD800..0xDFFF or code_point > 0x10FFFF,
       do: "\uFFFD"

  defp escaped_code_point(code_point), do: <<code_point::utf8>>

  @doc ~S"""
  Calls `fun` on each rule and declaration of a stylesheet, a list of them, or one of them, before
  their children (a rule's block), and returns what `fun` returns in their place: the node, a
  replacement, or nil to drop it, and then its children aren't walked.

  To sanitize, allow what's known to be safe rather than deny what isn't, and compare names
  `unescape/1`d and downcased, as they keep the escapes and case they were written in. Here,
  keeping only `@media` at-rules, and declarations without a URL or a function in them:

      iex> {:ok, stylesheet} =
      ...>   StylesheetParser.parse_stylesheet(
      ...>     ~S|@\69mport "x.css"; a { color: red; b\65havior: url(x.htc); width: \65xpression(alert(1)) } @MEDIA print { b { color: blue; background: u\72l(x.png) } }|
      ...>   )
      iex> sanitized =
      ...>   StylesheetParser.prewalk(stylesheet, fn
      ...>     %StylesheetParser.AtRule{name: name} = rule ->
      ...>       if name |> StylesheetParser.unescape() |> String.downcase() == "@media", do: rule
      ...>
      ...>     %StylesheetParser.Declaration{value: value} = declaration ->
      ...>       if Enum.all?(value, &match?({type, _} when type not in [:url, :bad_url], &1)),
      ...>         do: declaration
      ...>
      ...>     rule ->
      ...>       rule
      ...>   end)
      iex> to_string(sanitized)
      "a { color: red; }\n@MEDIA print { b { color: blue; } }"
  """
  def prewalk(node, fun), do: walk(node, fun, &keep/1)

  @doc """
  As `prewalk/2`, calling `fun` on each rule and declaration after their children.
  """
  def postwalk(node, fun), do: walk(node, &keep/1, fun)

  defp walk(node, pre, post) do
    {node, nil} =
      traverse(node, nil, fn node, nil -> {pre.(node), nil} end, fn node, nil ->
        {post.(node), nil}
      end)

    node
  end

  defp keep(node), do: node

  @doc """
  Walks the rules and declarations of a stylesheet, a list of them, or one of them, calling `pre`
  on each before its children (a rule's block) and `post` after, with an accumulator. Each returns
  `{node, acc}`, the node a replacement or nil to drop it; when `pre` drops one, its children
  aren't walked and `post` isn't called on it. Returns `{walked, acc}`.

      iex> {:ok, stylesheet} = StylesheetParser.parse_stylesheet("a { color: red; background: url(x.png) }")
      iex> url? = &match?({type, _} when type in [:url, :bad_url], &1)
      iex> {sanitized, dropped} =
      ...>   StylesheetParser.traverse(
      ...>     stylesheet,
      ...>     [],
      ...>     fn
      ...>       %StylesheetParser.Declaration{value: value} = declaration, dropped ->
      ...>         if Enum.any?(value, url?),
      ...>           do: {nil, [declaration | dropped]},
      ...>           else: {declaration, dropped}
      ...>
      ...>       node, dropped ->
      ...>         {node, dropped}
      ...>     end,
      ...>     fn node, dropped -> {node, dropped} end
      ...>   )
      iex> to_string(sanitized)
      "a { color: red; }"
      iex> Enum.map(dropped, &to_string/1)
      ["background: url(x.png);"]
  """
  def traverse(%Stylesheet{rules: rules} = stylesheet, acc, pre, post) do
    {rules, acc} = traverse(rules, acc, pre, post)
    {%{stylesheet | rules: rules}, acc}
  end

  def traverse(nodes, acc, pre, post) when is_list(nodes) do
    Enum.flat_map_reduce(nodes, acc, fn node, acc ->
      case traverse(node, acc, pre, post) do
        {nil, acc} -> {[], acc}
        {node, acc} -> {[node], acc}
      end
    end)
  end

  def traverse(node, acc, pre, post) do
    case pre.(node, acc) do
      {nil, acc} ->
        {nil, acc}

      {node, acc} ->
        {node, acc} = traverse_block(node, acc, pre, post)
        post.(node, acc)
    end
  end

  # A rule's children are its block's declarations and rules; an at-rule ending in `;` has none.
  defp traverse_block(%rule{block: block} = node, acc, pre, post)
       when rule in [QualifiedRule, AtRule] and is_list(block) do
    {block, acc} = traverse(block, acc, pre, post)
    {%{node | block: block}, acc}
  end

  defp traverse_block(node, acc, _pre, _post), do: {node, acc}
end
