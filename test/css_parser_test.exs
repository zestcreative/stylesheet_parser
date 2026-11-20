defmodule CssParserTest do
  use ExUnit.Case
  doctest CssParser
  alias CssParser.{AtRule, Declaration, QualifiedRule, Function, SimpleBlock, Stylesheet}
  alias CssParser.{CompoundSelector, SimpleSelector}
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

    test "a prelude that isn't selectors stays component values" do
      css = "@keyframes spin { from { opacity: 0; } 50% { opacity: 0.5; } }"

      assert {:ok, %Stylesheet{rules: [%AtRule{block: [from, half]}]}} =
               CssParser.parse_stylesheet(css)

      assert %QualifiedRule{prelude: [%SimpleSelector{type: :type, value: "from"}]} = from

      assert %QualifiedRule{prelude: [percentage: "50"], block: [%Declaration{name: "opacity"}]} =
               half
    end

    test "malformed input is an error where it is" do
      for {css, message} <- [
            {".card { color: var(--a; }", "1:16: unclosed var("},
            {".card { color red; }", "1:9: expected : after color"},
            {".card { 12px; }", "1:9: expected a declaration"},
            {".card", "1:1: expected { after the selector"}
          ] do
        assert {:error, %ParseError{} = error} = CssParser.parse_stylesheet(css)
        assert Exception.message(error) =~ message, "#{css}: #{Exception.message(error)}"
      end
    end

    test "an unclosed block is an error at its opening" do
      assert {:error, %ParseError{message: "unclosed {", line: 1, column: 7}} =
               CssParser.parse_stylesheet(".card {\n  color: red;\n")
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

      assert {:ok, declarations} = CssParser.parse_declarations(css)

      assert [
               %Declaration{name: "display", important: false, value: [ident: "block"]},
               %Declaration{name: "color", important: false, value: [hash: "#fefefe"]}
             ] = declarations

      assert Enum.map_join(declarations, " ", &to_string/1) == "display: block; color: #fefefe;"
    end

    test "returns important declarations" do
      css = "display: block;    color: #fefefe   !important "

      assert {:ok, declarations} = CssParser.parse_declarations(css)

      assert [
               %Declaration{name: "display", important: false, value: [ident: "block"]},
               %Declaration{name: "color", important: true, value: [hash: "#fefefe"]}
             ] = declarations

      assert Enum.map_join(declarations, " ", &to_string/1) ==
               "display: block; color: #fefefe !important;"
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

      assert {:ok, [print, width]} = CssParser.parse_rules(css)
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

  describe "positions" do
    test "each token starts at its line and column, past comments" do
      assert {:ok, tokens} = CssParser.tokenize("a {\n  /* note\n */ b: 1e+5;\n}")

      assert [
               {:ident, "a", {1, 1}},
               {:whitespace, " ", {1, 2}},
               {:lcurly, "{", {1, 3}},
               {:whitespace, "\n  ", {1, 4}},
               {:whitespace, " ", {3, 4}},
               {:ident, "b", {3, 5}},
               {:colon, ":", {3, 6}},
               {:whitespace, " ", {3, 7}},
               {:number, "1e+5", {3, 8}},
               {:semicolon, ";", {3, 12}},
               {:whitespace, "\n", {3, 13}},
               {:rcurly, "}", {4, 1}}
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

  describe "smoke test" do
    test "a stylesheet serializes to CSS that parses to the same rules" do
      css = File.read!("priv/sample.css")
      assert {:ok, stylesheet} = CssParser.parse_stylesheet(css)
      serialized = to_string(stylesheet)
      assert {:ok, again} = CssParser.parse_stylesheet(serialized)
      assert to_string(again) == serialized
    end
  end

  defp plain(tokens), do: Enum.map(tokens, fn {type, value, _position} -> {type, value} end)
end
