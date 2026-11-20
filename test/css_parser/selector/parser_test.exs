defmodule CssParser.Selector.ParserTest do
  use ExUnit.Case

  alias CssParser.{ComplexSelector, CompoundSelector, SimpleSelector}
  alias CssParser.Selector.Parser

  # Each selector parses completely and serializes back, with spaces around combinators.
  @round_trips [
    {"*", "*"},
    {"E", "E"},
    {"E.warning", "E.warning"},
    {"E#myid", "E#myid"},
    {".space-x-6>*+*", ".space-x-6 > * + *"},
    {"E:not(s1, s2, ...)", "E:not(s1, s2, ...)"},
    {"E:is(s1, s2, ...)", "E:is(s1, s2, ...)"},
    {"E:where(s1, s2, ...)", "E:where(s1, s2, ...)"},
    {"E:has(rs1, rs2, ...)", "E:has(rs1, rs2, ...)"},
    {"E:dir(ltr)", "E:dir(ltr)"},
    {~s|E:lang(zh, "*-hant")|, ~s|E:lang(zh, "*-hant")|},
    {"E:any-link", "E:any-link"},
    {"E:link", "E:link"},
    {"E:visited", "E:visited"},
    {"E:local-link", "E:local-link"},
    {"E:target", "E:target"},
    {"E:target-within", "E:target-within"},
    {"E:scope", "E:scope"},
    {"E:current", "E:current"},
    {"E:current(s)", "E:current(s)"},
    {"E:past", "E:past"},
    {"E:future", "E:future"},
    {"E F", "E F"},
    {"E > F", "E > F"},
    {"E>F", "E > F"},
    {"E + F", "E + F"},
    {"E+F", "E + F"},
    {"E ~ F", "E ~ F"},
    {"E~F", "E ~ F"},
    {"E || F", "E || F"},
    {"E||F", "E || F"},
    {"E[foo]", "E[foo]"},
    {~s|E[foo="bar"]|, ~s|E[foo="bar"]|},
    {~s|E[foo~="bar"]|, ~s|E[foo~="bar"]|},
    {~s|E[foo^="bar"]|, ~s|E[foo^="bar"]|},
    {~s|E[foo$="bar"]|, ~s|E[foo$="bar"]|},
    {~s|E[foo*="bar"]|, ~s|E[foo*="bar"]|},
    {~s|E[foo\|="bar"]|, ~s|E[foo\|="bar"]|},
    {~s|E[foo="bar" i]|, ~s|E[foo="bar" i]|},
    {~s|E[foo="bar" s]|, ~s|E[foo="bar" s]|},
    {".first span:nth-child(2n+1)", ".first span:nth-child(2n+1)"},
    {".first span:nth-child(2n+1),\n.second span:nth-child(2n+1),\n.third span:nth-of-type(2n+1)",
     ".first span:nth-child(2n+1), .second span:nth-child(2n+1), .third span:nth-of-type(2n+1)"}
  ]

  test "each selector parses completely and serializes back" do
    for {css, serialized} <- @round_trips do
      {selectors, rest} = css |> tokenize() |> Parser.selector_list()
      assert rest == [], "#{css} left #{inspect(rest)}"
      assert Enum.map_join(selectors, ", ", &to_string/1) == serialized
    end
  end

  describe "shapes" do
    test "a lone selector is a simple selector" do
      assert {[%SimpleSelector{type: :universal, value: "*"}], []} =
               Parser.selector_list(tokenize("*"))

      assert {[%SimpleSelector{type: :type, value: "E"}], []} =
               Parser.selector_list(tokenize("E"))

      assert {[%SimpleSelector{type: :class, value: ".card"}], []} =
               Parser.selector_list(tokenize(".card"))

      assert {[%SimpleSelector{type: :pseudo_class, value: ":root"}], []} =
               Parser.selector_list(tokenize(":root"))
    end

    test "selectors on one element are a compound selector" do
      assert {[%CompoundSelector{value: [type: "E", class: ".warning"]}], []} =
               Parser.selector_list(tokenize("E.warning"))

      assert {[%CompoundSelector{value: [type: "E", id: "#myid"]}], []} =
               Parser.selector_list(tokenize("E#myid"))

      assert {[%CompoundSelector{value: [type: "E", attribute: "[foo=\"bar\" i]"]}], []} =
               Parser.selector_list(tokenize(~s|E[foo="bar" i]|))

      assert {[%CompoundSelector{value: [type: "E", pseudo_class: ":dir(ltr)"]}], []} =
               Parser.selector_list(tokenize("E:dir(ltr)"))
    end

    test "combinators make a complex selector" do
      for {css, combinator} <- [
            {"E F", {:descendant_combinator, " "}},
            {"E > F", {:child_combinator, ">"}},
            {"E + F", {:sibling_combinator, "+"}},
            {"E ~ F", {:subsequent_combinator, "~"}},
            {"E || F", {:column_combinator, "||"}}
          ] do
        assert {[
                  %ComplexSelector{
                    value: [
                      %SimpleSelector{type: :type, value: "E"},
                      [^combinator, %SimpleSelector{type: :type, value: "F"}]
                    ]
                  }
                ], []} =
                 Parser.selector_list(tokenize(css))
      end
    end

    test "a selector list is one selector per comma" do
      {selectors, []} = Parser.selector_list(tokenize(".a, .b span, .c"))

      assert [%SimpleSelector{value: ".a"}, %ComplexSelector{}, %SimpleSelector{value: ".c"}] =
               selectors
    end
  end

  defp tokenize(css) do
    {:ok, tokens} = CssParser.tokenize(css)
    Enum.map(tokens, fn {type, value, _position} -> {type, value} end)
  end
end
