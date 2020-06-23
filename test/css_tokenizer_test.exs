defmodule CssTokenizerTest do
  use ExUnit.Case
  doctest CssTokenizer

  describe "build_at_rule" do
    test "returns atrule from @import" do
      css = """
      @import "https://www.w3.org/StyleSheets/TR/2016/base.css";
      """

      {:ok, tokens} = CssTokenizer.tokenize(css)
      tokens
      |> IO.inspect
      |> CssTokenizer.Stylesheet.build_at_rule
      |> IO.inspect
    end

    test "returns atrule from @media" do
      css = """
      @media only screen and (max-width: 600px) {
        body {
          background-color: lightblue;
        }
      }
      """

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

      assert {:ok, result} = CssTokenizer.tokenize(css)
      assert result == [
        {:ident, "pre"},
        {:delim, 46},
        {:ident, "html"},
        {:comma, ","},
        {:whitespace, " "},
        {:ident, "pre"},
        {:delim, 46},
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

      assert {:ok, result} = CssTokenizer.tokenize(css)
      assert result == [
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
end
