# Changelog

## v0.1.0

The first release.

- A CSS Syntax Level 3 tokenizer, each token with its line and column, and the parser entry
  points: a stylesheet, a list of rules, a rule, a declaration, a list of declarations, a
  component value and a list of component values.
- Error recovery as the spec has it: malformed CSS is dropped, and each
  `StylesheetParser.ParseError` kept with its line and column.
- CSS Nesting: blocks hold declarations and rules in order, with `&` and relative selectors.
- A Selectors Level 4 selector parser, with `:is()`, `:where()`, `:not()` and the `:nth-*()`
  pseudo-classes' arguments parsed, An+B as `{a, b}`.
- `prewalk/2`, `postwalk/2` and `traverse/4` to walk the rules and declarations, replacing or
  dropping them, as a sanitizer does, and `unescape/1` to decode the escapes in names before
  comparing them.
- `to_string/1` for everything parsed, which parses to the same rules again.
