defmodule CssParser.ParserTest do
  use ExUnit.Case
  alias CssParser.Parser
  doctest Parser

  describe "build_at_rule" do
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
      assert at_rule.block == %Parser.SimpleBlock{
        terminator: :rcurly,
        value: [
          {:whitespace, "\n  "},
          {:ident, "body"},
          {:whitespace, " "},
          %Parser.SimpleBlock{
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
        %Parser.SimpleBlock{
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
