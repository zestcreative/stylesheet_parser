defmodule CssParser.ParserTest do
  use ExUnit.Case
  alias CssParser.Syntax.Parser

  alias CssParser.{
    AtRule,
    ComplexSelector,
    CompoundSelector,
    Declaration,
    Function,
    PseudoClass,
    QualifiedRule,
    SimpleBlock,
    SimpleSelector
  }

  doctest Parser

  describe "build_at_rule" do
    test "returns An+B as {a, b}" do
      css = """
      .first span:nth-child(2n+1),
      .second span:nth-child(2n+1),
      .third span:nth-of-type(2n+1) {
        background-color: lime;
      }
      """

      {:ok, tokens} = CssParser.tokenize(css)
      {:ok, [rule], []} = Parser.parse_rules(tokens)

      assert %QualifiedRule{
               line: 1,
               column: 1,
               top_level: false,
               prelude: [
                 %ComplexSelector{
                   value: [
                     %SimpleSelector{type: :class, value: ".first"},
                     [
                       {:descendant_combinator, " "},
                       %CompoundSelector{
                         value: [
                           type: "span",
                           pseudo_class: %PseudoClass{name: "nth-child", an_b: {2, 1}}
                         ]
                       }
                     ]
                   ]
                 },
                 %ComplexSelector{},
                 %ComplexSelector{}
               ],
               block: [
                 %Declaration{
                   name: "background-color",
                   value: [ident: "lime"],
                   line: 4,
                   column: 3
                 }
               ]
             } = rule

      assert to_string(rule) ==
               ".first span:nth-child(2n+1), .second span:nth-child(2n+1), .third span:nth-of-type(2n+1) { background-color: lime; }"
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

      assert %AtRule{
               name: "@font-face",
               top_level: false,
               prelude: [],
               block: [
                 %Declaration{name: "font-family", value: [ident: "BBCBengali"]},
                 %Declaration{
                   name: "src",
                   value: [
                     {:url, "url(fonts/BBCBengali.woff)"},
                     {:whitespace, " "},
                     %Function{name: "format", value: [string: "\"woff\""]}
                   ]
                 },
                 %Declaration{
                   name: "unicode-range",
                   value: [urange: "U+00-FF", comma: ",", whitespace: " ", urange: "U+980-9FF"],
                   line: 4
                 }
               ]
             } = at_rule
    end

    test "returns atrule from @import" do
      css = """
      @import "https://www.w3.org/StyleSheets/TR/2016/base.css";
      """

      {:ok, tokens} = CssParser.tokenize(css)
      {:ok, at_rule, _rest} = Parser.build_at_rule(tokens)

      refute at_rule.block
      assert at_rule.top_level == false
      assert at_rule.name == "@import"
      assert at_rule.prelude == [{:string, ~s|"https://www.w3.org/StyleSheets/TR/2016/base.css"|}]
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

      assert [
               %QualifiedRule{
                 line: 2,
                 column: 3,
                 prelude: [%SimpleSelector{type: :type, value: "body"}],
                 block: [
                   %Declaration{
                     name: "background-color",
                     value: [ident: "lightblue"],
                     line: 3,
                     column: 5
                   }
                 ]
               }
             ] = at_rule.block

      assert [
               {:ident, "only"},
               {:whitespace, " "},
               {:ident, "screen"},
               {:whitespace, " "},
               {:ident, "and"},
               {:whitespace, " "},
               %SimpleBlock{
                 terminator: :rparen,
                 line: 1,
                 column: 24,
                 value: [
                   {:ident, "max-width"},
                   {:colon, ":"},
                   {:whitespace, " "},
                   {:dimension, ["600", "px"]}
                 ]
               }
             ] = at_rule.prelude
    end
  end
end
