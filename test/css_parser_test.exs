defmodule CssParserTest do
  use ExUnit.Case
  doctest CssParser
  alias CssParser.{AtRule, Declaration, QualifiedRule, Function, SimpleBlock, Stylesheet}
  alias CssParser.{ComplexSelector, CompoundSelector, SimpleSelector}
  alias CssParser.Syntax.Parser.ParseError

  describe "parse_stylesheet" do
    test "returns atrule from @import with toplevel as true" do
      css = """
      @import "https://www.w3.org/StyleSheets/TR/2016/base.css";
      """

      assert {:ok, %Stylesheet{rules: [at_rule]}} = CssParser.parse_stylesheet(css)

      assert %AtRule{
               top_level: true,
               block: nil,
               name: "@import",
               prelude: [string: "\"https://www.w3.org/StyleSheets/TR/2016/base.css\""],
               line: 1,
               column: 1
             } = at_rule

      assert to_string(at_rule) == ~s|@import "https://www.w3.org/StyleSheets/TR/2016/base.css";|
    end

    test "returns qualified rules, stylesheet, and serializes" do
      css = """
      pre.ascii-art {
        display: table; /* shrinkwrap */
        margin: 1em auto;
        line-height: normal;
      }

      /* Displaying the output of text layout, particularly when
        line-breaking is being invoked, and thus having a
        visible width is good. */
      pre.output {
        margin: 1em;
        border: solid thin silver;
        padding: 0.25em;
        display: table;
      }
      """

      assert {:ok, %Stylesheet{rules: [one, two]} = stylesheet} = CssParser.parse_stylesheet(css)

      assert %QualifiedRule{
               top_level: true,
               line: 1,
               column: 1,
               prelude: [%CompoundSelector{value: [type: "pre", class: ".ascii-art"]}],
               block: [
                 %Declaration{name: "display", value: [ident: "table"], line: 2, column: 3},
                 %Declaration{
                   name: "margin",
                   value: [dimension: ["1", "em"], whitespace: " ", ident: "auto"]
                 },
                 %Declaration{name: "line-height", value: [ident: "normal"]}
               ]
             } = one

      assert %QualifiedRule{
               line: 10,
               prelude: [%CompoundSelector{value: [type: "pre", class: ".output"]}],
               block: [
                 %Declaration{name: "margin", value: [dimension: ["1", "em"]], line: 11},
                 %Declaration{
                   name: "border",
                   value: [
                     ident: "solid",
                     whitespace: " ",
                     ident: "thin",
                     whitespace: " ",
                     ident: "silver"
                   ]
                 },
                 %Declaration{name: "padding", value: [dimension: ["0.25", "em"]]},
                 %Declaration{name: "display", value: [ident: "table"]}
               ]
             } = two

      assert to_string(one) ==
               "pre.ascii-art { display: table; margin: 1em auto; line-height: normal; }"

      assert to_string(stylesheet) ==
               "pre.ascii-art { display: table; margin: 1em auto; line-height: normal; }\n" <>
                 "pre.output { margin: 1em; border: solid thin silver; padding: 0.25em; display: table; }"
    end

    test "a rule-list at-rule's block is its rules" do
      css = """
      :root { --status-success: #1a7f37; }
      @media (prefers-color-scheme: dark) {
        :root { --status-success: #3fb950; }
      }
      """

      assert {:ok, %Stylesheet{rules: [root, media]}} = CssParser.parse_stylesheet(css)

      assert %QualifiedRule{prelude: [%SimpleSelector{type: :pseudo_class, value: ":root"}]} =
               root

      assert %AtRule{
               name: "@media",
               line: 2,
               prelude: [
                 %SimpleBlock{
                   terminator: :rparen,
                   value: [
                     ident: "prefers-color-scheme",
                     colon: ":",
                     whitespace: " ",
                     ident: "dark"
                   ]
                 }
               ],
               block: [
                 %QualifiedRule{
                   top_level: false,
                   line: 3,
                   column: 3,
                   block: [
                     %Declaration{
                       name: "--status-success",
                       value: [hash: "#3fb950"],
                       line: 3,
                       column: 11
                     }
                   ]
                 }
               ]
             } = media

      assert to_string(media) ==
               "@media (prefers-color-scheme: dark) { :root { --status-success: #3fb950; } }"
    end

    test "a keyframe's prelude is its component values" do
      css = "@keyframes spin { from { opacity: 0; } 50% { opacity: 0.5; } }"

      assert {:ok, %Stylesheet{rules: [%AtRule{block: [from, half]}], errors: []}} =
               CssParser.parse_stylesheet(css)

      assert %QualifiedRule{prelude: [ident: "from"]} = from

      assert %QualifiedRule{prelude: [percentage: "50"], block: [%Declaration{name: "opacity"}]} =
               half
    end

    test "malformed input is dropped and its errors kept where they are" do
      for {css, messages} <- [
            {".card { color: var(--a; }", ["1:16: unclosed var(", "1:7: unclosed {"]},
            {".card { color red; }", ["1:9: expected : after color"]},
            {".card { 12px; }", ["1:9: expected a declaration"]},
            {".card", ["1:1: expected { after the selector"]},
            {"#1a { color: red }", ["1:1: invalid selector"]}
          ] do
        assert {:ok, %Stylesheet{errors: errors}} = CssParser.parse_stylesheet(css)
        assert Enum.map(errors, &Exception.message/1) == messages, css
      end
    end

    test "an unclosed block closes at the end, an error at its opening" do
      assert {:ok,
              %Stylesheet{
                rules: [%QualifiedRule{block: [%Declaration{name: "color"}]}],
                errors: [%ParseError{message: "unclosed {", line: 1, column: 7}]
              }} = CssParser.parse_stylesheet(".card {\n  color: red;\n")
    end
  end

  describe "parses functions" do
    test "returns a function and serializes" do
      css = "color: rgb(0,1,2, 0.5);"

      assert {:ok, declaration} = CssParser.parse_declaration(css)
      assert %Declaration{value: [%Function{name: "rgb", line: 1, column: 8}]} = declaration
      assert to_string(declaration) == "color: rgb(0,1,2, 0.5);"
    end
  end

  describe "parse_declaration" do
    test "returns a declaration and serializes" do
      css = "    display: block  "

      assert {:ok, declaration} = CssParser.parse_declaration(css)

      assert %Declaration{
               name: "display",
               important: false,
               value: [ident: "block"],
               line: 1,
               column: 5
             } = declaration

      assert to_string(declaration) == "display: block;"
    end

    test "returns an important declaration" do
      css = "    color: #fefefe   !important "

      assert {:ok, declaration} = CssParser.parse_declaration(css)
      assert %Declaration{name: "color", important: true, value: [hash: "#fefefe"]} = declaration
      assert to_string(declaration) == "color: #fefefe !important;"
    end
  end

  describe "parse_declarations" do
    test "returns a declaration" do
      css = "    display: block;  color: #fefefe;  "

      assert {:ok, declarations, []} = CssParser.parse_declarations(css)

      assert [
               %Declaration{name: "display", important: false, value: [ident: "block"]},
               %Declaration{name: "color", important: false, value: [hash: "#fefefe"]}
             ] = declarations

      assert Enum.map_join(declarations, " ", &to_string/1) == "display: block; color: #fefefe;"
    end

    test "returns important declarations" do
      css = "display: block;    color: #fefefe   !important "

      assert {:ok, declarations, []} = CssParser.parse_declarations(css)

      assert [
               %Declaration{name: "display", important: false, value: [ident: "block"]},
               %Declaration{name: "color", important: true, value: [hash: "#fefefe"]}
             ] = declarations

      assert Enum.map_join(declarations, " ", &to_string/1) ==
               "display: block; color: #fefefe !important;"
    end

    test "returns the errors of what it dropped" do
      assert {:ok, [%Declaration{name: "color"}], [error]} =
               CssParser.parse_declarations("margin 0; color: red")

      assert Exception.message(error) == "1:1: expected : after margin"
    end
  end

  describe "parse_rule" do
    test "parses one rule; more than one is an error" do
      css = """
      @media print {
        #navigation { display: none; }
      }
      """

      assert {:ok, at_rule} = CssParser.parse_rule(css)

      assert %AtRule{
               top_level: false,
               name: "@media",
               prelude: [ident: "print"],
               block: [
                 %QualifiedRule{
                   prelude: [%SimpleSelector{type: :id, value: "#navigation"}],
                   block: [%Declaration{name: "display", value: [ident: "none"]}]
                 }
               ]
             } = at_rule

      assert to_string(at_rule) == "@media print { #navigation { display: none; } }"

      assert {:error, %ParseError{message: "expected one rule", line: 5}} =
               CssParser.parse_rule(
                 css <> "\n@media (width < 1024px) { #navigation { display: block; } }"
               )
    end
  end

  describe "parse_rules" do
    test "atrules have toplevel set to false" do
      css = """
      @media print {
        #navigation { display: none; }
      }

      @media (width < 1024px) {
        #navigation { display: block; }
      }
      """

      assert {:ok, [print, width], []} = CssParser.parse_rules(css)
      assert %AtRule{top_level: false, name: "@media", prelude: [ident: "print"], line: 1} = print

      assert %AtRule{
               top_level: false,
               name: "@media",
               line: 5,
               prelude: [
                 %SimpleBlock{
                   terminator: :rparen,
                   value: [
                     ident: "width",
                     whitespace: " ",
                     delim: "<",
                     whitespace: " ",
                     dimension: ["1024", "px"]
                   ]
                 }
               ],
               block: [
                 %QualifiedRule{block: [%Declaration{name: "display", value: [ident: "block"]}]}
               ]
             } = width
    end
  end

  describe "parse_rules errors" do
    test "returns the errors of what it dropped" do
      assert {:ok, [%QualifiedRule{}], [error]} = CssParser.parse_rules("#1a { } b { }")
      assert Exception.message(error) == "1:1: invalid selector"
    end
  end

  describe "positions" do
    test "each token starts at its line and column, past comments" do
      assert {:ok, tokens} = CssParser.tokenize("a {\n  /* note\n */ b: 1e+5;\n}")

      assert [
               {:ident, "a", [line: 1, column: 1]},
               {:whitespace, " ", [line: 1, column: 2]},
               {:lcurly, "{", [line: 1, column: 3]},
               {:whitespace, "\n  ", [line: 1, column: 4]},
               {:whitespace, " ", [line: 3, column: 4]},
               {:ident, "b", [line: 3, column: 5]},
               {:colon, ":", [line: 3, column: 6]},
               {:whitespace, " ", [line: 3, column: 7]},
               {:number, "1e+5", [line: 3, column: 8]},
               {:semicolon, ";", [line: 3, column: 12]},
               {:whitespace, "\n", [line: 3, column: 13]},
               {:rcurly, "}", [line: 4, column: 1]}
             ] = tokens
    end
  end

  describe "tokenize" do
    test "tokenizes CSS" do
      css = """
      pre.html, pre.xml {
        padding: 0.5em;
        margin: 1em 0;
        position: relative;
        clear: both;
        color: #600;
      }
      """

      assert {:ok, result} = CssParser.tokenize(css)

      assert plain(result) == [
               {:ident, "pre"},
               {:delim, "."},
               {:ident, "html"},
               {:comma, ","},
               {:whitespace, " "},
               {:ident, "pre"},
               {:delim, "."},
               {:ident, "xml"},
               {:whitespace, " "},
               {:lcurly, "{"},
               {:whitespace, "\n  "},
               {:ident, "padding"},
               {:colon, ":"},
               {:whitespace, " "},
               {:dimension, ["0.5", "em"]},
               {:semicolon, ";"},
               {:whitespace, "\n  "},
               {:ident, "margin"},
               {:colon, ":"},
               {:whitespace, " "},
               {:dimension, ["1", "em"]},
               {:whitespace, " "},
               {:number, "0"},
               {:semicolon, ";"},
               {:whitespace, "\n  "},
               {:ident, "position"},
               {:colon, ":"},
               {:whitespace, " "},
               {:ident, "relative"},
               {:semicolon, ";"},
               {:whitespace, "\n  "},
               {:ident, "clear"},
               {:colon, ":"},
               {:whitespace, " "},
               {:ident, "both"},
               {:semicolon, ";"},
               {:whitespace, "\n  "},
               {:ident, "color"},
               {:colon, ":"},
               {:whitespace, " "},
               {:hash, "#600"},
               {:semicolon, ";"},
               {:whitespace, "\n"},
               {:rcurly, "}"},
               {:whitespace, "\n"}
             ]
    end

    test "tokenizes CSS in style tag" do
      css = "padding: 0.5em; margin: 1em 0; position: relative; clear: both; color: #600;"

      assert {:ok, result} = CssParser.tokenize(css)

      assert plain(result) == [
               {:ident, "padding"},
               {:colon, ":"},
               {:whitespace, " "},
               {:dimension, ["0.5", "em"]},
               {:semicolon, ";"},
               {:whitespace, " "},
               {:ident, "margin"},
               {:colon, ":"},
               {:whitespace, " "},
               {:dimension, ["1", "em"]},
               {:whitespace, " "},
               {:number, "0"},
               {:semicolon, ";"},
               {:whitespace, " "},
               {:ident, "position"},
               {:colon, ":"},
               {:whitespace, " "},
               {:ident, "relative"},
               {:semicolon, ";"},
               {:whitespace, " "},
               {:ident, "clear"},
               {:colon, ":"},
               {:whitespace, " "},
               {:ident, "both"},
               {:semicolon, ";"},
               {:whitespace, " "},
               {:ident, "color"},
               {:colon, ":"},
               {:whitespace, " "},
               {:hash, "#600"},
               {:semicolon, ";"}
             ]
    end
  end

  describe "tokenize, against the spec" do
    test "each token is the spec's, its value its source text" do
      for {css, tokens} <- [
            # Idents: An+B is a dimension and a number; non-ASCII and escaped code points.
            {"evenodd", [ident: "evenodd"]},
            {".even-row", [delim: ".", ident: "even-row"]},
            {"2n+1", [dimension: ["2", "n"], number: "+1"]},
            {"café", [ident: "café"]},
            {~S"a\:b", [ident: ~S"a\:b"]},
            {~S"\31 0", [ident: ~S"\31 0"]},
            {"--x", [ident: "--x"]},
            {"-->", [cdc: "-->"]},
            # Strings: escapes, to the end, and a newline makes a bad string.
            {~S("a\"b"), [string: ~S("a\"b")]},
            {~S("abc), [string: ~S("abc)]},
            {"\"ab\ncd", [bad_string: "\"ab", whitespace: "\n", ident: "cd"]},
            # Comments run to the end.
            {"a /* never closed", [ident: "a", whitespace: " "]},
            # url(: a url token, a function before a quote, or a bad url.
            {"URL(a.png)", [url: "URL(a.png)"]},
            {"url( a.png )", [url: "url( a.png )"]},
            {~S|url("a.png")|, [function: "url(", string: ~S("a.png"), rparen: ")"]},
            {"url(a b)", [bad_url: "url(a b)"]},
            {"url(a", [url: "url(a"]},
            # Numbers
            {"1.", [number: "1", delim: "."]},
            {"1e3 1em -.5%",
             [
               number: "1e3",
               whitespace: " ",
               dimension: ["1", "em"],
               whitespace: " ",
               percentage: "-.5"
             ]},
            # Preprocessing
            {"a\rb\r\nc\fd",
             [
               ident: "a",
               whitespace: "\n",
               ident: "b",
               whitespace: "\n",
               ident: "c",
               whitespace: "\n",
               ident: "d"
             ]},
            {<<"a", 0, "b">>, [ident: "a�b"]}
          ] do
        assert {:ok, result} = CssParser.tokenize(css)
        assert plain(result) == tokens, inspect(css)
      end
    end
  end

  describe "parse_stylesheet, recovering" do
    test "a malformed declaration is dropped, and the rest kept" do
      assert {:ok, %Stylesheet{rules: [a, b], errors: errors}} =
               CssParser.parse_stylesheet("a { color red; *zoom: 1; margin: 0 } b { x: y }")

      assert %QualifiedRule{block: [%Declaration{name: "margin"}]} = a
      assert %QualifiedRule{block: [%Declaration{name: "x"}]} = b

      assert Enum.map(errors, &Exception.message/1) ==
               ["1:5: expected : after color", "1:16: expected a declaration"]
    end

    test "a rule whose selectors don't parse is dropped" do
      assert {:ok,
              %Stylesheet{
                rules: [%QualifiedRule{prelude: [%SimpleSelector{value: "b"}]}],
                errors: [error]
              }} =
               CssParser.parse_stylesheet("a, { color: red } b { color: blue }")

      assert Exception.message(error) == "1:1: invalid selector"
    end

    test "rules nest in style rules, with relative selectors and &" do
      css =
        "a { color: red; &:hover { color: blue } > b { x: y } .c { x: y } @media print { color: green } }"

      assert {:ok, %Stylesheet{rules: [rule], errors: []}} = CssParser.parse_stylesheet(css)

      assert %QualifiedRule{
               block: [
                 %Declaration{name: "color"},
                 %QualifiedRule{
                   prelude: [%CompoundSelector{value: [nesting: "&", pseudo_class: ":hover"]}]
                 },
                 %QualifiedRule{
                   prelude: [
                     %ComplexSelector{
                       value: [[{:child_combinator, ">"}, %SimpleSelector{value: "b"}]]
                     }
                   ]
                 },
                 %QualifiedRule{prelude: [%SimpleSelector{type: :class, value: ".c"}]},
                 %AtRule{name: "@media", block: [%Declaration{name: "color"}]}
               ]
             } = rule

      assert to_string(rule) ==
               "a { color: red; &:hover { color: blue; } > b { x: y; } .c { x: y; } @media print { color: green; } }"
    end

    test "a custom property's value may be a {} block" do
      assert {:ok,
              %Stylesheet{rules: [%QualifiedRule{block: [%Declaration{name: "--x"}]}], errors: []}} =
               CssParser.parse_stylesheet("a { --x: { b: c } }")
    end

    test "url() with a quoted string is a function" do
      assert {:ok, %Stylesheet{rules: [%QualifiedRule{block: [declaration]}]}} =
               CssParser.parse_stylesheet(~S|a { background: url("x.png") }|)

      assert %Declaration{value: [%Function{name: "url", value: [string: ~S("x.png")]}]} =
               declaration
    end
  end

  describe "serializing" do
    test "tokens a comment separated stay separate" do
      assert {:ok, stylesheet} =
               CssParser.parse_stylesheet("a { margin: 1px/**/2px; font: x/**/y }")

      assert to_string(stylesheet) == "a { margin: 1px/**/2px; font: x/**/y; }"
      assert {:ok, again} = CssParser.parse_stylesheet(to_string(stylesheet))
      assert to_string(again) == to_string(stylesheet)
    end
  end

  describe "smoke test" do
    test "a stylesheet serializes to CSS that parses to the same rules" do
      css = File.read!("priv/sample.css")
      assert {:ok, stylesheet} = CssParser.parse_stylesheet(css)
      serialized = to_string(stylesheet)
      assert {:ok, again} = CssParser.parse_stylesheet(serialized)
      assert to_string(again) == serialized
    end
  end

  defp plain(tokens), do: Enum.map(tokens, fn {type, value, _metadata} -> {type, value} end)
end
