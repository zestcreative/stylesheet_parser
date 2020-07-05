defmodule CssParser.ParserTest do
  use ExUnit.Case
  alias CssParser.Syntax.Parser
  alias CssParser.{Declaration, QualifiedRule, Function, SimpleBlock}
  doctest Parser

  describe "build_at_rule" do
    test "returns a+bn tokens" do
      css = """
      .first span:nth-child(2n+1),
      .second span:nth-child(2n+1),
      .third span:nth-of-type(2n+1) {
        background-color: lime;
      }
      """

      {:ok, tokens} = CssParser.tokenize(css)
      {:ok, [rule]} = Parser.parse_rules(tokens)

      assert rule == %QualifiedRule{
        block: %SimpleBlock{
          terminator: :rcurly,
          value: [
            whitespace: "\n  ",
            ident: "background-color",
            colon: ":",
            whitespace: " ",
            ident: "lime",
            semicolon: ";",
            whitespace: "\n"
          ]
        },
        prelude: [
          class_selector: ".first",
          descendant_combinator: " ",
          compound_selector: [type_selector: "span", pseudo_class_selector: ":nth-child(2n+1)"],
          class_selector: ".second",
          descendant_combinator: " ",
          compound_selector: [type_selector: "span", pseudo_class_selector: ":nth-child(2n+1)"],
          class_selector: ".third",
          descendant_combinator: " ",
          compound_selector: [type_selector: "span", pseudo_class_selector: ":nth-of-type(2n+1)"]
        ],
        value: [
          %Declaration{important: false, name: "background-color", value: [ident: "lime"]}
        ],
        top_level: false
      }
    end

    test "returns uranges" do
      css = """
      @font-face {
        font-family: BBCBengali;
        src: url(fonts/BBCBengali.woff) format("woff");
        unicode-range: U+00-FF, U+980-9FF;
      }
      """

      {:ok, tokens} = CssParser.tokenize(css)
      {:ok, at_rule, _rest} = Parser.build_at_rule(tokens)

      assert at_rule.block == %SimpleBlock{
        terminator: :rcurly,
        value: [
          {:whitespace, "\n  "},
          {:ident, "font-family"},
          {:colon, ":"},
          {:whitespace, " "},
          {:ident, "BBCBengali"},
          {:semicolon, ";"},
          {:whitespace, "\n  "},
          {:ident, "src"},
          {:colon, ":"},
          {:whitespace, " "},
          {:url, "url(fonts/BBCBengali.woff)"},
          {:whitespace, " "},
          %Function{name: "format(", value: [string: "\"woff\""]},
          {:semicolon, ";"},
          {:whitespace, "\n  "},
          {:ident, "unicode-range"},
          {:colon, ":"},
          {:whitespace, " "},
          {:urange, "U+00-FF"},
          {:comma, ","},
          {:whitespace, " "},
          {:urange, "U+980-9FF"},
          {:semicolon, ";"},
          {:whitespace, "\n"}
        ]
      }
      assert at_rule.value == []
      assert at_rule.top_level == false
      assert at_rule.name == "@font-face"
      assert at_rule.prelude == [{:whitespace, " "}]
    end

    test "returns atrule from @import" do
      css = """
      @import "https://www.w3.org/StyleSheets/TR/2016/base.css";
      """

      {:ok, tokens} = CssParser.tokenize(css)
      {:ok, at_rule, _rest} = Parser.build_at_rule(tokens)

      refute at_rule.block
      assert at_rule.value == []
      assert at_rule.top_level == false
      assert at_rule.name == "@import"
      assert at_rule.prelude == [
        {:whitespace, " "},
        {:string, ~s|"https://www.w3.org/StyleSheets/TR/2016/base.css"|}
      ]
    end

    test "returns atrule from @media" do
      css = """
      @media only screen and (max-width: 600px) {
        body {
          background-color: lightblue;
        }
      }
      """

      {:ok, tokens} = CssParser.tokenize(css)
      {:ok, at_rule, _rest} = Parser.build_at_rule(tokens)

      assert at_rule.name == "@media"
      assert at_rule.value == []
      assert at_rule.block == %SimpleBlock{
        terminator: :rcurly,
        value: [
          {:whitespace, "\n  "},
          {:ident, "body"},
          {:whitespace, " "},
          %SimpleBlock{
            terminator: :rcurly,
            value: [
              whitespace: "\n    ",
              ident: "background-color",
              colon: ":",
              whitespace: " ",
              ident: "lightblue",
              semicolon: ";",
              whitespace: "\n  "
            ]
          },
          {:whitespace, "\n"},
        ]
      }
      assert at_rule.prelude == [
        {:whitespace, " "},
        {:ident, "only"},
        {:whitespace, " "},
        {:ident, "screen"},
        {:whitespace, " "},
        {:ident, "and"},
        {:whitespace, " "},
        %SimpleBlock{
          terminator: :rparen,
          value: [
            {:ident, "max-width"},
            {:colon, ":"},
            {:whitespace, " "},
            {:dimension, ["600", "px"]},
          ]
        },
        {:whitespace, " "}
      ]
    end
  end
end
