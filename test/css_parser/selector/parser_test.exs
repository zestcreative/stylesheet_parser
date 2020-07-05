defmodule CssParser.Selector.ParserTest do
  use ExUnit.Case

  alias CssParser.Selector.Parser

  describe "multiple selectors" do
    test "returns a list for each selector" do
      tokens = """
      .first span:nth-child(2n+1),
      .second span:nth-child(2n+1),
      .third span:nth-of-type(2n+1) {
        background-color: lime;
      }
      """ |> tokenize()

      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [universal_selector: "*"]
    end
  end

  describe "universal" do
    test "universal selectors" do
      tokens = "*" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [universal_selector: "*"]
    end

    test "type selectors" do
      tokens = "E" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [type_selector: "E"]
    end
  end

  describe "selectors" do
    test "class selectors" do
      tokens = "E.warning " |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        class_selector: ".warning"
      ]
    end

    test "type selectors" do
      tokens = "E" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [type_selector: "E"]
    end

    test "ID selectors" do
      tokens = "E#myid " |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        id_selector: "#myid"
      ]
    end

    test "compound selectors" do
      tokens = ".space-x-6>*+*" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        class_selector: ".space-x-6",
        child_combinator: ">",
        compound_selector: [universal_selector: "*"],
        sibling_combinator: "+",
        compound_selector: [universal_selector: "*"]
      ]
    end
  end

  describe "pseudo-class" do
    test ":not" do
      tokens = "E:not(s1, s2, ...)" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        pseudo_class_selector: ":not(s1, s2, ..."
      ]
    end

    test ":is" do
      tokens = "E:is(s1, s2, ...)" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        pseudo_class_selector: ":is(s1, s2, ..."
      ]
    end

    test ":where" do
      tokens = "E:where(s1, s2, ...)" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        pseudo_class_selector: ":where(s1, s2, ..."
      ]
    end

    test ":has" do
      tokens = "E:has(rs1, rs2, ...)" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        pseudo_class_selector: ":has(rs1, rs2, ..."
      ]
    end

    test ":dir" do
      tokens = "E:dir(ltr)" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        pseudo_class_selector: ":dir(ltr"
      ]
    end

    test ":lang" do
      tokens = "E:lang(zh, \"*-hant\")" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        pseudo_class_selector: ":lang(zh, \"*-hant\""
      ]
    end

    test ":any-link" do
      tokens = "E:any-link" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        pseudo_class_selector: ":any-link"
      ]
    end

    test ":link" do
      tokens = "E:link" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        pseudo_class_selector: ":link"
      ]
    end

    test ":visited" do
      tokens = "E:visited" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        pseudo_class_selector: ":visited"
      ]
    end

    test ":local-link" do
      tokens = "E:local-link" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        pseudo_class_selector: ":local-link"
      ]
    end

    test ":target" do
      tokens = "E:target" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        pseudo_class_selector: ":target"
      ]
    end

    test ":target-within" do
      tokens = "E:target-within" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        pseudo_class_selector: ":target-within"
      ]
    end

    test ":scope" do
      tokens = "E:scope" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        pseudo_class_selector: ":scope"
      ]
    end

    test ":current" do
      tokens = "E:current" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        pseudo_class_selector: ":current"
      ]
    end

    test ":current(s)" do
      tokens = "E:current(s)" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        pseudo_class_selector: ":current(s"
      ]
    end

    test ":past" do
      tokens = "E:past" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        pseudo_class_selector: ":past"
      ]
    end

    test ":future" do
      tokens = "E:future" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        pseudo_class_selector: ":future"
      ]
    end
  end

  describe "combinators" do
    test "descendant" do
      tokens = "E F" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        descendant_combinator: " ",
        compound_selector: [type_selector: "F"]
      ]
    end

    test "child" do
      tokens = "E > F" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        child_combinator: ">",
        compound_selector: [type_selector: "F"]
      ]

      tokens = "E>F" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        child_combinator: ">",
        compound_selector: [type_selector: "F"]
      ]
    end

    test "sibling" do
      tokens = "E + F" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        sibling_combinator: "+",
        compound_selector: [type_selector: "F"]
      ]

      tokens = "E+F" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        sibling_combinator: "+",
        compound_selector: [type_selector: "F"]
      ]
    end

    test "subsequent" do
      tokens = "E ~ F" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        subsequent_combinator: "~",
        compound_selector: [type_selector: "F"]
      ]

      tokens = "E~F" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        subsequent_combinator: "~",
        compound_selector: [type_selector: "F"]
      ]
    end

    test "column" do
      tokens = "E || F" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        column_combinator: "||",
        compound_selector: [type_selector: "F"]
      ]

      tokens = "E||F" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        column_combinator: "||",
        compound_selector: [type_selector: "F"]
      ]
    end
  end

  describe "attribute selectors" do
    test "attribute selectors without a value" do
      tokens = "E[foo]" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        attribute_selector: "[foo]"
      ]
    end

    test "attribute selectors with a value" do
      tokens = "E[foo=\"bar\"]" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        attribute_selector: "[foo=\"bar\"]"
      ]
    end

    test "attribute selectors with an exact value" do
      tokens = "E[foo~=\"bar\"]" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        attribute_selector: "[foo~=\"bar\"]"
      ]
    end

    test "attribute selectors with a value beginning with" do
      tokens = "E[foo^=\"bar\"]" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        attribute_selector: "[foo^=\"bar\"]"
      ]
    end

    test "attribute selectors with a value ending with" do
      tokens = "E[foo$=\"bar\"]" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        attribute_selector: "[foo$=\"bar\"]"
      ]
    end

    test "attribute selectors with a value containing" do
      tokens = "E[foo*=\"bar\"]" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        attribute_selector: "[foo*=\"bar\"]"
      ]
    end

    test "attribute selectors with a hyphen-separated list beginning with" do
      tokens = "E[foo|=\"bar\"]" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        attribute_selector: "[foo|=\"bar\"]"
      ]
    end

    test "attribute modifiers" do
      tokens = "E[foo=\"bar\" i]" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        attribute_selector: "[foo=\"bar\" i]"
      ]

      tokens = "E[foo=\"bar\" s]" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        type_selector: "E",
        attribute_selector: "[foo=\"bar\" s]"
      ]
    end

    test "combination class, descendant_combinator, and pseudoclass on type" do
      tokens = ".first span:nth-child(2n+1)" |> tokenize()
      {selectors, _} = Parser.selector_list(tokens)

      assert selectors == [
        class_selector: ".first",
        descendant_combinator: " ",
        compound_selector: [type_selector: "span", pseudo_class_selector: ":nth-child(2n+1"]
      ]
    end
  end

  defp tokenize(css) do
    {:ok, tokens, _, _, _, _} = CssParser.Syntax.Tokenizer.consume(css)
    tokens
  end
end
