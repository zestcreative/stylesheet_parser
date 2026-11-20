defmodule StylesheetParser.Selector.ParserTest do
  use ExUnit.Case

  alias StylesheetParser.{
    ComplexSelector,
    CompoundSelector,
    Function,
    PseudoClass,
    SimpleSelector
  }

  alias StylesheetParser.Selector.Parser

  # Each selector parses completely and serializes back, with spaces around combinators.
  @round_trips [
    {"*", "*"},
    {"E", "E"},
    {"E.warning", "E.warning"},
    {"E#myid", "E#myid"},
    {".space-x-6>*+*", ".space-x-6 > * + *"},
    {"E:not(.a, .b > c)", "E:not(.a, .b > c)"},
    {"E:is(.a, .b > c)", "E:is(.a, .b > c)"},
    {"E:where(.a, .b > c)", "E:where(.a, .b > c)"},
    {"E:is(.a, ::before, 1px, .b)", "E:is(.a, .b)"},
    {"E:is()", "E:is()"},
    {"E:not(:is(.a):hover)", "E:not(:is(.a):hover)"},
    {"E:nth-child(odd)", "E:nth-child(2n+1)"},
    {"E:nth-child(2n + 1 of .a, .b)", "E:nth-child(2n+1 of .a, .b)"},
    {"E:nth-last-of-type(-n+3)", "E:nth-last-of-type(-n+3)"},
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
    {"ns|*", "ns|*"},
    {"*|*", "*|*"},
    {"ns|E", "ns|E"},
    {"E[foo=bar]", "E[foo=bar]"},
    {~s|E[ foo = "bar" I ]|, ~s|E[foo="bar" I]|},
    {"E::part(label)", "E::part(label)"},
    {"E /* c */ > /* d */ F", "E > F"},
    {"E , F", "E, F"},
    {".a\\:b", ".a\\:b"},
    {".café", ".café"},
    {".even-row", ".even-row"},
    {"&.a", "&.a"},
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

      assert {[
                %CompoundSelector{
                  value: [type: "E", pseudo_class: %Function{name: "dir", value: [ident: "ltr"]}]
                }
              ], []} =
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

    test "what isn't a selector doesn't parse completely" do
      for css <-
            ["a,", "#1a", "a::before.b", "> a", "[a=]", ~s|[a="b" x]|] ++
              ["a:not(.b, 1px)", "a:not(::before)", "a:not()", "a:nth-child(2n+)"] ++
              ["a:nth-child(+ n)", "a:nth-child(1.5)", "a:nth-of-type(2n of .b)"] do
        assert {_selectors, [_ | _]} = Parser.selector_list(tokenize(css)), css
      end
    end

    test ":not(), :is() and :where() hold their selectors" do
      assert {[%CompoundSelector{value: [type: "a", pseudo_class: not_selector]}], []} =
               Parser.selector_list(tokenize("a:NOT(.b, c d)"))

      assert %PseudoClass{
               name: "NOT",
               an_b: nil,
               selectors: [%SimpleSelector{type: :class, value: ".b"}, %ComplexSelector{}]
             } = not_selector
    end

    test ":nth-*() hold An+B, as {a, b}, and :nth-child() its selectors after of" do
      for {an_b, a_and_b} <- [
            {"odd", {2, 1}},
            {"EVEN", {2, 0}},
            {"5", {0, 5}},
            {"-5", {0, -5}},
            {"n", {1, 0}},
            {"+n", {1, 0}},
            {"-n", {-1, 0}},
            {"3n", {3, 0}},
            {"2n+1", {2, 1}},
            {"2n-1", {2, -1}},
            {"2n- 1", {2, -1}},
            {"2n -1", {2, -1}},
            {"2n + 1", {2, 1}},
            {" -n+3 ", {-1, 3}},
            {"n-1", {1, -1}},
            {"+n-1", {1, -1}},
            {"-n-1", {-1, -1}},
            {"-n- 1", {-1, -1}},
            {"N+1", {1, 1}}
          ] do
        assert {[%SimpleSelector{type: :pseudo_class, value: %PseudoClass{an_b: ^a_and_b}}], []} =
                 Parser.selector_list(tokenize(":nth-child(#{an_b})")),
               an_b
      end

      assert {[
                %SimpleSelector{
                  value: %PseudoClass{an_b: {2, 1}, selectors: [%SimpleSelector{value: ".a"}]}
                }
              ], []} =
               Parser.selector_list(tokenize(":nth-child(2n+1 of .a)"))
    end

    test "a relative selector starts with its combinator" do
      assert {[
                %ComplexSelector{value: [[{:child_combinator, ">"}, %SimpleSelector{value: "a"}]]} =
                  selector,
                b
              ], []} =
               Parser.relative_selector_list(tokenize("> a, b"))

      assert %SimpleSelector{value: "b"} = b
      assert to_string(selector) == "> a"
    end

    test "a selector list is one selector per comma" do
      {selectors, []} = Parser.selector_list(tokenize(".a, .b span, .c"))

      assert [%SimpleSelector{value: ".a"}, %ComplexSelector{}, %SimpleSelector{value: ".c"}] =
               selectors
    end
  end

  # Selectors parse component values, as a rule's prelude is.
  defp tokenize(css) do
    {:ok, values} = StylesheetParser.parse_component_values(css)
    values
  end
end
