# CssParser

A [CSS Syntax Level 3](https://www.w3.org/TR/css-syntax-3/) tokenizer and parser in Elixir, with
a [Selectors Level 4](https://www.w3.org/TR/selectors-4/) selector parser.

```elixir
{:ok, stylesheet} =
  CssParser.parse_stylesheet("""
  :root { --space-s: 6px; }
  @media (prefers-color-scheme: dark) { :root { --text: #ececf0; } }
  .card > .title { padding: var(--space-s) 12px; }
  """)

[root, media, card] = stylesheet.rules
%CssParser.QualifiedRule{prelude: [%CssParser.SimpleSelector{type: :pseudo_class, value: ":root"}]} = root
%CssParser.AtRule{name: "@media", block: [%CssParser.QualifiedRule{}]} = media

%CssParser.QualifiedRule{
  line: 3,
  block: [%CssParser.Declaration{name: "padding", value: [%CssParser.Function{name: "var"}, {:whitespace, " "}, {:dimension, ["12", "px"]}]}]
} = card
```

- Tokens are `{type, value, metadata}`, like Elixir AST, with `[line: l, column: c]` metadata. Rules, declarations, functions and simple blocks
  carry the `line` and `column` where they start; the values inside them are `{type, value}`.
- A qualified rule's `prelude` is its selector list, and its `block` its declarations. An at-rule
  whose block holds rules (`@media`, `@supports`, …) has its rules as its `block`; others have
  their declarations.
- Malformed input is `{:error, %CssParser.Syntax.Parser.ParseError{message, line, column}}`.
- `to_string/1` serializes what it parsed. Comments are dropped and whitespace normalized, so the
  output parses to the same rules again.
