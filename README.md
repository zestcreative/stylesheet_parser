# StylesheetParser

[![Hex.pm](https://img.shields.io/hexpm/v/stylesheet_parser.svg)](https://hex.pm/packages/stylesheet_parser)
[![Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/stylesheet_parser)
[![CI](https://github.com/zestcreative/stylesheet_parser/actions/workflows/ci.yml/badge.svg)](https://github.com/zestcreative/stylesheet_parser/actions/workflows/ci.yml)

A [CSS Syntax Level 3](https://www.w3.org/TR/css-syntax-3/) tokenizer and parser in Elixir, with
[CSS Nesting](https://www.w3.org/TR/css-nesting-1/) and a
[Selectors Level 4](https://www.w3.org/TR/selectors-4/) selector parser. It has no runtime
dependencies.

## Installation

```elixir
def deps do
  [
    {:stylesheet_parser, "~> 0.1"}
  ]
end
```

## Usage

```elixir
{:ok, stylesheet} =
  StylesheetParser.parse_stylesheet("""
  :root { --space-s: 6px; }
  @media (prefers-color-scheme: dark) { :root { --text: #ececf0; } }
  .card > .title { padding: var(--space-s) 12px; }
  """)

%StylesheetParser.Stylesheet{rules: [root, media, card], errors: []} = stylesheet
%StylesheetParser.QualifiedRule{prelude: [%StylesheetParser.SimpleSelector{type: :pseudo_class, value: ":root"}]} = root
%StylesheetParser.AtRule{name: "@media", block: [%StylesheetParser.QualifiedRule{}]} = media

%StylesheetParser.QualifiedRule{
  line: 3,
  block: [%StylesheetParser.Declaration{name: "padding", value: [%StylesheetParser.Function{name: "var"}, {:whitespace, " "}, {:dimension, ["12", "px"]}]}]
} = card
```

- Tokens are `{type, value, metadata}`, like Elixir AST, with `[line: l, column: c]` metadata. Rules, declarations, functions and simple blocks
  carry the `line` and `column` where they start; the values inside them are `{type, value}`.
- A token's value is its source text: strings keep their quotes, and escapes stay escaped.
- A qualified rule's `prelude` is its selector list (in `@keyframes`, its component values, such
  as `50%`). A block, a style rule's or an at-rule's, is its declarations and rules in order, with
  [nested](https://www.w3.org/TR/css-nesting-1/) style rules and `&`. `:is()`, `:where()`,
  `:not()` and the `:nth-*()` pseudo-classes are a `StylesheetParser.PseudoClass` of their parsed
  selectors and An+B, `{a, b}`.
- Malformed input is dropped as the spec recovers from it, and each
  `%StylesheetParser.ParseError{message, line, column}` is in the stylesheet's `errors`: a
  declaration with no colon, a rule whose selectors don't parse, an unclosed block.
- `StylesheetParser.prewalk/2`, `postwalk/2` and `traverse/4` walk the rules and declarations,
  to replace or drop them, such as to sanitize what can load or run code. Names keep their
  escapes as written (`b\65havior` is `behavior` to a browser), so compare them
  `StylesheetParser.unescape/1`d.
- `to_string/1` serializes what it parsed. Comments are dropped (a `/**/` stays only where two
  tokens would otherwise run together) and whitespace normalized, so the output parses to the same
  rules again.

See the [documentation](https://hexdocs.pm/stylesheet_parser) for the parser entry points and the
structs they return.
