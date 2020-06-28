defmodule CssParserTest do
  use ExUnit.Case
  doctest CssParser
  alias CssParser.Parser

  describe "parse_stylesheet" do
    test "returns atrule from @import with toplevel as true" do
      css = """
      @import "https://www.w3.org/StyleSheets/TR/2016/base.css";
      """

      assert {:ok, stylesheet} = CssParser.parse_stylesheet(css)
      expected_at_rule =
        %Parser.AtRule{
          top_level: true,
          block: nil,
          name: "@import",
          prelude: [
            whitespace: " ",
            string: "\"https://www.w3.org/StyleSheets/TR/2016/base.css\""
          ],
          value: []
        }

      assert stylesheet == %Parser.Stylesheet{rules: [expected_at_rule]}
      assert to_string(expected_at_rule) ==
      ~s|@import "https://www.w3.org/StyleSheets/TR/2016/base.css";|
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

      assert {:ok, stylesheet} = CssParser.parse_stylesheet(css)
      [expected_rule_one, expected_rule_two] = expected_qualified_rules = [
        %Parser.QualifiedRule{
          block: %Parser.SimpleBlock{
            terminator: :rcurly,
            value: [
              whitespace: "\n  ",
              ident: "display",
              colon: ":",
              whitespace: " ",
              ident: "table",
              semicolon: ";",
              whitespace: " ",
              whitespace: "\n  ",
              ident: "margin",
              colon: ":",
              whitespace: " ",
              dimension: ["1", "em"],
              whitespace: " ",
              ident: "auto",
              semicolon: ";",
              whitespace: "\n  ",
              ident: "line-height",
              colon: ":",
              whitespace: " ",
              ident: "normal",
              semicolon: ";",
              whitespace: "\n"
            ]
          },
          prelude: [
            {:ident, "pre"},
            {:delim, "."},
            {:ident, "ascii-art"},
            {:whitespace, " "}
          ],
          top_level: true,
          value: [
            %Parser.Declaration{important: false, name: "display", value: [ident: "table"]},
            %Parser.Declaration{important: false, name: "margin", value: [dimension: ["1", "em"], ident: "auto"]},
            %Parser.Declaration{important: false, name: "line-height", value: [ident: "normal"]}
          ]
        },
        %CssParser.Parser.QualifiedRule{
          block: %CssParser.Parser.SimpleBlock{
            terminator: :rcurly,
            value: [
              whitespace: "\n  ",
              ident: "margin",
              colon: ":",
              whitespace: " ",
              dimension: ["1", "em"],
              semicolon: ";",
              whitespace: "\n  ",
              ident: "border",
              colon: ":",
              whitespace: " ",
              ident: "solid",
              whitespace: " ",
              ident: "thin",
              whitespace: " ",
              ident: "silver",
              semicolon: ";",
              whitespace: "\n  ",
              ident: "padding",
              colon: ":",
              whitespace: " ",
              dimension: ["0.25", "em"],
              semicolon: ";",
              whitespace: "\n  ",
              ident: "display",
              colon: ":",
              whitespace: " ",
              ident: "table",
              semicolon: ";",
              whitespace: "\n"
            ]
          },
          prelude: [
            {:ident, "pre"},
            {:delim, "."},
            {:ident, "output"},
            {:whitespace, " "}
          ],
          top_level: true,
          value: [
            %Parser.Declaration{important: false, name: "margin", value: [dimension: ["1", "em"]]},
            %Parser.Declaration{important: false, name: "border", value: [ident: "solid", ident: "thin", ident: "silver"]},
            %Parser.Declaration{important: false, name: "padding", value: [dimension: ["0.25", "em"]]},
            %Parser.Declaration{important: false, name: "display", value: [ident: "table"]}
          ]
        }
      ]

      assert stylesheet == %Parser.Stylesheet{rules: expected_qualified_rules}
      assert to_string(expected_rule_one) ==
        "pre.ascii-art {\n  display: table; \n  margin: 1em auto;\n  line-height: normal;\n}\n"
      assert to_string(expected_rule_two) ==
        "pre.output {\n  margin: 1em;\n  border: solid thin silver;\n  padding: 0.25em;\n  display: table;\n}\n"

      assert to_string(stylesheet) ==
        "pre.ascii-art {\n  display: table; \n  margin: 1em auto;\n  line-height: normal;\n}\npre.output {\n  margin: 1em;\n  border: solid thin silver;\n  padding: 0.25em;\n  display: table;\n}\n"
    end

  #   test "returns a stylesheet" do
  #     css = File.read!("priv/sample.css")
  #
  #     assert {:ok, stylesheet} = CssParser.parse_stylesheet(css)
  #     assert stylesheet == %Parser.Stylesheet{rules: [
  #       %Parser.AtRule{
  #         top_level: true,
  #         block: nil,
  #         name: "@import",
  #         prelude: [
  #           whitespace: " ",
  #           string: "\"https://www.w3.org/StyleSheets/TR/2016/base.css\""
  #         ],
  #         value: []
  #       },
  #       %Parser.AtRule{
  #         top_level: true,
  #         block: %Parser.SimpleBlock{
  #         },
  #         name: "@media",
  #         prelude: [
  #           whitespace: " ",
  #           string: "\"https://www.w3.org/StyleSheets/TR/2016/base.css\""
  #         ],
  #         value: []
  #       }
  #     ]}
  #   end
  end

  describe "parses functions" do
    test "returns a function and serializes" do
      css = "color: rgb(0,1,2, 0.5);"

      assert {:ok, rule} = CssParser.parse_declaration(css)

      assert to_string(rule) ==
        "color: rgb(0,1,2, 0.5);"
    end

  end

  describe "parse_declaration" do
    test "returns a declaration and serializes" do
      css = "    display: block  "

      assert {:ok, declaration} = CssParser.parse_declaration(css)
      expected_declaration =
        %Parser.Declaration{
          name: "display",
          important: false,
          value: [{:ident, "block"}]
        }
      assert declaration == expected_declaration

      assert to_string(expected_declaration) ==
        "display: block;"
    end

    test "returns an important declaration" do
      css = "    color: #fefefe   !important "

      assert {:ok, declaration} = CssParser.parse_declaration(css)
      expected_declaration =
        %Parser.Declaration{
          name: "color",
          important: true,
          value: [{:hash, "#fefefe"}]
        }
      assert declaration == expected_declaration

      assert to_string(expected_declaration) ==
        "color: #fefefe !important;"
    end
  end

  describe "parse_declarations" do
    test "returns a declaration" do
      css = "    display: block;  color: #fefefe;  "

      assert {:ok, declarations} = CssParser.parse_declarations(css)
      assert declarations == [
        %Parser.Declaration{
          name: "display",
          important: false,
          value: [{:ident, "block"}]
        },
        %Parser.Declaration{
          name: "color",
          important: false,
          value: [{:hash, "#fefefe"}]
        }
      ]

      assert declarations |> Enum.map(&to_string/1) |> Enum.join(" ") ==
        "display: block; color: #fefefe;"
    end

    test "returns important declarations" do
      css = "display: block;    color: #fefefe   !important "

      assert {:ok, declarations} = CssParser.parse_declarations(css)
      assert declarations == [
        %Parser.Declaration{
          name: "display",
          important: false,
          value: [{:ident, "block"}]
        },
        %Parser.Declaration{
          name: "color",
          important: true,
          value: [{:hash, "#fefefe"}]
        }
      ]

      assert declarations |> Enum.map(&to_string/1) |> Enum.join(" ") ==
        "display: block; color: #fefefe !important;"
    end
  end

  describe "parse_rule" do
    test "atrules have toplevel set to false" do
      css = """
      @media print {
        #navigation { display: none; }
      }

      @media (width < 1024px) {
        #navigation { display: block; }
      }
      """

      expected_at_rule =
        %Parser.AtRule{
          top_level: false,
          block: %Parser.SimpleBlock{
            terminator: :rcurly,
            value: [
              {:whitespace, "\n  "},
              {:hash, "#navigation"},
              {:whitespace, " "},
              %CssParser.Parser.SimpleBlock{
                terminator: :rcurly,
                value: [
                  whitespace: " ",
                  ident: "display",
                  colon: ":",
                  whitespace: " ",
                  ident: "none",
                  semicolon: ";",
                  whitespace: " "
                ]
              },
              {:whitespace, "\n"},
            ]
          },
          name: "@media",
          prelude: [
            {:whitespace, " "},
            {:ident, "print"},
            {:whitespace, " "}
          ],
          value: []
        }

      # The second @media will be ignored.
      assert {:ok, at_rule} = CssParser.parse_rule(css)
      assert at_rule == expected_at_rule

      assert to_string(expected_at_rule) ==
        "@media print {\n  #navigation { display: none; }\n}\n"
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

      assert {:ok, rules} = CssParser.parse_rules(css)
      assert rules == [
          %Parser.AtRule{
            top_level: false,
            block: %Parser.SimpleBlock{
              terminator: :rcurly,
              value: [
                {:whitespace, "\n  "},
                {:hash, "#navigation"},
                {:whitespace, " "},
                %CssParser.Parser.SimpleBlock{
                  terminator: :rcurly,
                  value: [
                    whitespace: " ",
                    ident: "display",
                    colon: ":",
                    whitespace: " ",
                    ident: "none",
                    semicolon: ";",
                    whitespace: " "
                  ]
                },
                {:whitespace, "\n"}
              ]
            },
            name: "@media",
            prelude: [
              {:whitespace, " "},
              {:ident, "print"},
              {:whitespace, " "}
            ],
            value: []
          },
          %Parser.AtRule{
            top_level: false,
            name: "@media",
            block: %Parser.SimpleBlock{
              terminator: :rcurly,
              value: [
                {:whitespace, "\n  "},
                {:hash, "#navigation"},
                {:whitespace, " "},
                %Parser.SimpleBlock{
                  terminator: :rcurly,
                  value: [
                    whitespace: " ",
                    ident: "display",
                    colon: ":",
                    whitespace: " ",
                    ident: "block",
                    semicolon: ";",
                    whitespace: " "
                  ]
                },
                {:whitespace, "\n"},
              ]
            },
            prelude: [
              {:whitespace, " "},
              %Parser.SimpleBlock{
                terminator: :rparen,
                value: [
                  ident: "width",
                  whitespace: " ",
                  delim: "<",
                  whitespace: " ",
                  dimension: ["1024", "px"]
                ]
              },
              {:whitespace, " "},
            ],
            value: []
          }
        ]
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
      assert result == [
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
