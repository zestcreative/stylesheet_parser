defmodule CssParserTest do
  use ExUnit.Case
  doctest CssParser
  alias CssParser.Syntax.Parser

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
        %Parser.QualifiedRule{
          block: %Parser.SimpleBlock{
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
              %Parser.SimpleBlock{
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
                %Parser.SimpleBlock{
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

  describe "smoke test" do
    test "returns a stylesheet" do
      css = File.read!("priv/sample.css")

      assert {:ok, stylesheet} = CssParser.parse_stylesheet(css) |> IO.inspect

      %Parser.Stylesheet{
        rules: [
          %Parser.AtRule{
            block: nil,
            name: "@import",
            prelude: [
              whitespace: " ",
              string: "\"https://www.w3.org/StyleSheets/TR/2016/base.css\""
            ],
            top_level: true,
            value: []
          },
          %Parser.AtRule{
            block: %Parser.SimpleBlock{
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
                {:whitespace, "\n"}
              ]
            },
            name: "@media",
            prelude: [
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
                  ident: "max-width",
                  colon: ":",
                  whitespace: " ",
                  dimension: ["600", "px"]
                ]
              },
              {:whitespace, " "}
            ],
            top_level: true,
            value: []
          },
          %Parser.QualifiedRule{
            block: %Parser.SimpleBlock{
              terminator: :rcurly,
              value: [
                whitespace: "\n\t\t",
                ident: "padding",
                colon: ":",
                whitespace: " ",
                dimension: ["0.5", "em"],
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "margin",
                colon: ":",
                whitespace: " ",
                dimension: ["1", "em"],
                whitespace: " ",
                number: "0",
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "position",
                colon: ":",
                whitespace: " ",
                ident: "relative",
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "clear",
                colon: ":",
                whitespace: " ",
                ident: "both",
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "color",
                colon: ":",
                whitespace: " ",
                hash: "#600",
                semicolon: ";",
                whitespace: "\n\t"
              ]
            },
            prelude: [
              ident: "div",
              delim: ".",
              ident: "html",
              comma: ",",
              whitespace: " ",
              ident: "div",
              delim: ".",
              ident: "xml",
              comma: ",",
              whitespace: "\n\t",
              ident: "pre",
              delim: ".",
              ident: "html",
              comma: ",",
              whitespace: " ",
              ident: "pre",
              delim: ".",
              ident: "xml",
              whitespace: " "
            ],
            top_level: true,
            value: [
              %Parser.Declaration{
                important: false,
                name: "padding",
                value: [dimension: ["0.5", "em"]]
              },
              %Parser.Declaration{
                important: false,
                name: "margin",
                value: [dimension: ["1", "em"], number: "0"]
              },
              %Parser.Declaration{
                important: false,
                name: "position",
                value: [ident: "relative"]
              },
              %Parser.Declaration{
                important: false,
                name: "clear",
                value: [ident: "both"]
              },
              %Parser.Declaration{
                important: false,
                name: "color",
                value: [hash: "#600"]
              }
            ]
          },
          %Parser.QualifiedRule{
            block: %Parser.SimpleBlock{
              terminator: :rcurly,
              value: [
                whitespace: "\n\t\t",
                ident: "padding-top",
                colon: ":",
                whitespace: " ",
                dimension: ["1.5", "em"],
                semicolon: ";",
                whitespace: "\n\t"
              ]
            },
            prelude: [
              ident: "pre",
              delim: ".",
              ident: "example",
              comma: ",",
              whitespace: "\n\t",
              ident: "pre",
              delim: ".",
              ident: "html",
              comma: ",",
              whitespace: "\n\t",
              ident: "pre",
              delim: ".",
              ident: "xml",
              whitespace: " "
            ],
            top_level: true,
            value: [
              %Parser.Declaration{
                important: false,
                name: "padding-top",
                value: [dimension: ["1.5", "em"]]
              }
            ]
          },
          %Parser.QualifiedRule{
            block: %Parser.SimpleBlock{
              terminator: :rcurly,
              value: [
                whitespace: "\n\t\t",
                ident: "color",
                colon: ":",
                whitespace: " ",
                ident: "red",
                semicolon: ";",
                whitespace: "\n\t"
              ]
            },
            prelude: [
              ident: "pre",
              delim: ".",
              ident: "illegal",
              comma: ",",
              whitespace: " ",
              delim: ".",
              ident: "illegal",
              whitespace: " ",
              ident: "pre",
              whitespace: "\n\t",
              ident: "pre",
              delim: ".",
              ident: "deprecated",
              comma: ",",
              whitespace: " ",
              delim: ".",
              ident: "deprecated",
              whitespace: " ",
              ident: "pre",
              whitespace: " "
            ],
            top_level: true,
            value: [
              %Parser.Declaration{
                important: false,
                name: "color",
                value: [ident: "red"]
              }
            ]
          },
          %Parser.QualifiedRule{
            block: %Parser.SimpleBlock{
              terminator: :rcurly,
              value: [
                whitespace: "\n\t\t",
                ident: "color",
                colon: ":",
                whitespace: " ",
                hash: "#660000",
                semicolon: ";",
                whitespace: "\n\t"
              ]
            },
            prelude: [
              ident: "code",
              delim: ".",
              ident: "html",
              comma: ",",
              whitespace: " ",
              ident: "code",
              delim: ".",
              ident: "xml",
              whitespace: " "
            ],
            top_level: true,
            value: [
              %Parser.Declaration{
                important: false,
                name: "color",
                value: [hash: "#660000"]
              }
            ]
          },
          %Parser.QualifiedRule{
            block: %Parser.SimpleBlock{
              terminator: :rcurly,
              value: [
                whitespace: "\n\t\t",
                ident: "display",
                colon: ":",
                whitespace: " ",
                ident: "table",
                semicolon: ";",
                whitespace: " ",
                whitespace: "\n\t\t",
                ident: "margin",
                colon: ":",
                whitespace: " ",
                dimension: ["1", "em"],
                whitespace: " ",
                ident: "auto",
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "line-height",
                colon: ":",
                whitespace: " ",
                ident: "normal",
                semicolon: ";",
                whitespace: "\n\t"
              ]
            },
            prelude: [ident: "pre", delim: ".", ident: "ascii-art", whitespace: " "],
            top_level: true,
            value: [
              %Parser.Declaration{
                important: false,
                name: "display",
                value: [ident: "table"]
              },
              %Parser.Declaration{
                important: false,
                name: "margin",
                value: [dimension: ["1", "em"], ident: "auto"]
              },
              %Parser.Declaration{
                important: false,
                name: "line-height",
                value: [ident: "normal"]
              }
            ]
          },
          %Parser.QualifiedRule{
            block: %Parser.SimpleBlock{
              terminator: :rcurly,
              value: [
                whitespace: "\n\t\t",
                ident: "margin",
                colon: ":",
                whitespace: " ",
                dimension: ["1", "em"],
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "border",
                colon: ":",
                whitespace: " ",
                ident: "solid",
                whitespace: " ",
                ident: "thin",
                whitespace: " ",
                ident: "silver",
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "padding",
                colon: ":",
                whitespace: " ",
                dimension: ["0.25", "em"],
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "display",
                colon: ":",
                whitespace: " ",
                ident: "table",
                semicolon: ";",
                whitespace: "\n\t"
              ]
            },
            prelude: [ident: "pre", delim: ".", ident: "output", whitespace: " "],
            top_level: true,
            value: [
              %Parser.Declaration{
                important: false,
                name: "margin",
                value: [dimension: ["1", "em"]]
              },
              %Parser.Declaration{
                important: false,
                name: "border",
                value: [ident: "solid", ident: "thin", ident: "silver"]
              },
              %Parser.Declaration{
                important: false,
                name: "padding",
                value: [dimension: ["0.25", "em"]]
              },
              %Parser.Declaration{
                important: false,
                name: "display",
                value: [ident: "table"]
              }
            ]
          },
          %Parser.QualifiedRule{
            block: %Parser.SimpleBlock{
              terminator: :rcurly,
              value: [
                whitespace: "\n\t\t",
                ident: "page-break-inside",
                colon: ":",
                whitespace: " ",
                ident: "avoid",
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "width",
                colon: ":",
                whitespace: " ",
                percentage: "100",
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "margin",
                colon: ":",
                whitespace: " ",
                dimension: ["1.2", "em"],
                whitespace: " ",
                number: "0",
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "border-left",
                colon: ":",
                whitespace: " ",
                dimension: ["0.5", "em"],
                whitespace: " ",
                ident: "solid",
                whitespace: " ",
                hash: "#8CCBF2",
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "padding",
                colon: ":",
                whitespace: " ",
                dimension: [...],
                ...
              ]
            },
            prelude: [
              ident: "table",
              delim: ".",
              ident: "propdef",
              comma: ",",
              whitespace: " ",
              ident: "table",
              delim: ".",
              ident: "propdef-extra",
              comma: ",",
              whitespace: "\n\t",
              ident: "table",
              delim: ".",
              ident: "descdef",
              comma: ",",
              whitespace: " ",
              ident: "table",
              delim: ".",
              ident: "definition-table",
              whitespace: " "
            ],
            top_level: true,
            value: [
              %Parser.Declaration{
                important: false,
                name: "page-break-inside",
                value: [ident: "avoid"]
              },
              %Parser.Declaration{
                important: false,
                name: "width",
                value: [percentage: "100"]
              },
              %Parser.Declaration{
                important: false,
                name: "margin",
                value: [dimension: ["1.2", "em"], number: "0"]
              },
              %Parser.Declaration{
                important: false,
                name: "border-left",
                value: [dimension: ["0.5", "em"], ident: "solid", hash: "#8CCBF2"]
              },
              %Parser.Declaration{
                important: false,
                name: "padding",
                value: [dimension: ["0.5", "em"], dimension: ["1", "em"]]
              },
              %Parser.Declaration{
                important: false,
                name: "background",
                value: [hash: "#DEF"]
              },
              %Parser.Declaration{
                important: false,
                name: "border-spacing",
                value: [number: "0"]
              }
            ]
          },
          %Parser.QualifiedRule{
            block: %Parser.SimpleBlock{
              terminator: :rcurly,
              value: [
                whitespace: "\n\t\t",
                ident: "padding",
                colon: ":",
                whitespace: " ",
                dimension: ["0.5", "em"],
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "vertical-align",
                colon: ":",
                whitespace: " ",
                ident: "baseline",
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "border-bottom",
                colon: ":",
                whitespace: " ",
                dimension: ["1", "px"],
                whitespace: " ",
                ident: "solid",
                whitespace: " ",
                hash: "#bbd7e9",
                semicolon: ";",
                whitespace: "\n\t"
              ]
            },
            prelude: [
              ident: "table",
              delim: ".",
              ident: "propdef",
              whitespace: " ",
              ident: "td",
              comma: ",",
              whitespace: " ",
              ident: "table",
              delim: ".",
              ident: "propdef-extra",
              whitespace: " ",
              ident: "td",
              comma: ",",
              whitespace: "\n\t",
              ident: "table",
              delim: ".",
              ident: "descdef",
              whitespace: " ",
              ident: "td",
              comma: ",",
              whitespace: " ",
              ident: "table",
              delim: ".",
              ident: "definition-table",
              whitespace: " ",
              ident: "td",
              comma: ",",
              whitespace: "\n\t",
              ident: "table",
              delim: ".",
              ident: "propdef",
              whitespace: " ",
              ident: "th",
              comma: ",",
              whitespace: " ",
              ...
            ],
            top_level: true,
            value: [
              %Parser.Declaration{
                important: false,
                name: "padding",
                value: [dimension: ["0.5", "em"]]
              },
              %Parser.Declaration{
                important: false,
                name: "vertical-align",
                value: [ident: "baseline"]
              },
              %Parser.Declaration{
                important: false,
                name: "border-bottom",
                value: [dimension: ["1", "px"], ident: "solid", hash: "#bbd7e9"]
              }
            ]
          },
          %Parser.QualifiedRule{
            block: %Parser.SimpleBlock{
              terminator: :rcurly,
              value: [
                whitespace: "\n\t\t",
                ident: "border-bottom",
                colon: ":",
                whitespace: " ",
                number: "0",
                semicolon: ";",
                whitespace: "\n\t"
              ]
            },
            prelude: [
              ident: "table",
              delim: ".",
              ident: "propdef",
              whitespace: " ",
              delim: ">",
              whitespace: " ",
              ident: "tbody",
              whitespace: " ",
              delim: ">",
              whitespace: " ",
              ident: "tr",
              colon: ":",
              ident: "last-child",
              whitespace: " ",
              ident: "th",
              comma: ",",
              whitespace: "\n\t",
              ident: "table",
              delim: ".",
              ident: "propdef-extra",
              whitespace: " ",
              delim: ">",
              whitespace: " ",
              ident: "tbody",
              whitespace: " ",
              delim: ">",
              whitespace: " ",
              ident: "tr",
              colon: ":",
              ident: "last-child",
              whitespace: " ",
              ident: "th",
              comma: ",",
              whitespace: "\n\t",
              ...
            ],
            top_level: true,
            value: [
              %Parser.Declaration{
                important: false,
                name: "border-bottom",
                value: [number: "0"]
              }
            ]
          },
          %Parser.QualifiedRule{
            block: %Parser.SimpleBlock{
              terminator: :rcurly,
              value: [
                whitespace: "\n\t\t",
                ident: "font-style",
                colon: ":",
                whitespace: " ",
                ident: "italic",
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "font-weight",
                colon: ":",
                whitespace: " ",
                ident: "normal",
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "width",
                colon: ":",
                whitespace: " ",
                dimension: ["8.3", "em"],
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "padding-left",
                colon: ":",
                whitespace: " ",
                dimension: ["1", "em"],
                semicolon: ";",
                whitespace: "\n\t"
              ]
            },
            prelude: [
              ident: "table",
              delim: ".",
              ident: "propdef",
              whitespace: " ",
              ident: "th",
              comma: ",",
              whitespace: "\n\t",
              ident: "table",
              delim: ".",
              ident: "propdef-extra",
              whitespace: " ",
              ident: "th",
              comma: ",",
              whitespace: "\n\t",
              ident: "table",
              delim: ".",
              ident: "descdef",
              whitespace: " ",
              ident: "th",
              comma: ",",
              whitespace: "\n\t",
              ident: "table",
              delim: ".",
              ident: "definition-table",
              whitespace: " ",
              ident: "th",
              whitespace: " "
            ],
            top_level: true,
            value: [
              %Parser.Declaration{
                important: false,
                name: "font-style",
                value: [ident: "italic"]
              },
              %Parser.Declaration{
                important: false,
                name: "font-weight",
                value: [ident: "normal"]
              },
              %Parser.Declaration{
                important: false,
                name: "width",
                value: [dimension: ["8.3", "em"]]
              },
              %Parser.Declaration{
                important: false,
                name: "padding-left",
                value: [dimension: ["1", "em"]]
              }
            ]
          },
          %Parser.QualifiedRule{
            block: %Parser.SimpleBlock{
              terminator: :rcurly,
              value: [
                whitespace: "\n\t\t",
                ident: "white-space",
                colon: ":",
                whitespace: " ",
                ident: "pre-wrap",
                semicolon: ";",
                whitespace: "\n\t"
              ]
            },
            prelude: [
              ident: "table",
              whitespace: " ",
              ident: "td",
              delim: ".",
              ident: "pre",
              whitespace: " "
            ],
            top_level: true,
            value: [
              %Parser.Declaration{
                important: false,
                name: "white-space",
                value: [ident: "pre-wrap"]
              }
            ]
          },
          %Parser.QualifiedRule{
            block: %Parser.SimpleBlock{
              terminator: :rcurly,
              value: [
                whitespace: "\n\t\t",
                ident: "padding-top",
                colon: ":",
                whitespace: " ",
                dimension: ["0.6", "em"],
                semicolon: ";",
                whitespace: "\n\t"
              ]
            },
            prelude: [
              ident: "table",
              delim: ".",
              ident: "propdef",
              whitespace: " ",
              ident: "td",
              delim: ".",
              ident: "footnote",
              comma: ",",
              whitespace: "\n\t",
              ident: "table",
              delim: ".",
              ident: "propdef-extra",
              whitespace: " ",
              ident: "td",
              delim: ".",
              ident: "footnote",
              comma: ",",
              whitespace: "\n\t",
              ident: "table",
              delim: ".",
              ident: "descdef",
              whitespace: " ",
              ident: "td",
              delim: ".",
              ident: "footnote",
              comma: ",",
              whitespace: "\n\t",
              ident: "table",
              delim: ".",
              ident: "definition-table",
              whitespace: " ",
              ...
            ],
            top_level: true,
            value: [
              %Parser.Declaration{
                important: false,
                name: "padding-top",
                value: [dimension: ["0.6", "em"]]
              }
            ]
          },
          %Parser.QualifiedRule{
            block: %Parser.SimpleBlock{
              terminator: :rcurly,
              value: [
                whitespace: "\n\t\t",
                ident: "content",
                colon: ":",
                whitespace: " ",
                string: "\" \"",
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "display",
                colon: ":",
                whitespace: " ",
                ident: "block",
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "height",
                colon: ":",
                whitespace: " ",
                dimension: ["0.6", "em"],
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "width",
                colon: ":",
                whitespace: " ",
                dimension: ["4", "em"],
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "border-top",
                colon: ":",
                whitespace: " ",
                ident: "thin",
                ...
              ]
            },
            prelude: [
              ident: "table",
              delim: ".",
              ident: "propdef",
              whitespace: " ",
              ident: "td",
              delim: ".",
              ident: "footnote",
              colon: ":",
              colon: ":",
              ident: "before",
              comma: ",",
              whitespace: "\n\t",
              ident: "table",
              delim: ".",
              ident: "propdef-extra",
              whitespace: " ",
              ident: "td",
              delim: ".",
              ident: "footnote",
              colon: ":",
              colon: ":",
              ident: "before",
              comma: ",",
              whitespace: "\n\t",
              ident: "table",
              delim: ".",
              ident: "descdef",
              whitespace: " ",
              ident: "td",
              delim: ".",
              ...
            ],
            top_level: true,
            value: [
              %Parser.Declaration{
                important: false,
                name: "content",
                value: [string: "\" \""]
              },
              %Parser.Declaration{
                important: false,
                name: "display",
                value: [ident: "block"]
              },
              %Parser.Declaration{
                important: false,
                name: "height",
                value: [dimension: ["0.6", "em"]]
              },
              %Parser.Declaration{
                important: false,
                name: "width",
                value: [dimension: ["4", "em"]]
              },
              %Parser.Declaration{
                important: false,
                name: "border-top",
                value: [ident: "thin", ident: "solid"]
              }
            ]
          },
          %Parser.QualifiedRule{
            block: %Parser.SimpleBlock{
              terminator: :rcurly,
              value: [
                whitespace: "\n\t\t",
                ident: "background",
                colon: ":",
                whitespace: " ",
                hash: "#00589f",
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "color",
                colon: ":",
                whitespace: " ",
                hash: "#fff",
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "text-align",
                colon: ":",
                whitespace: " ",
                ident: "left",
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "padding",
                colon: ":",
                whitespace: " ",
                dimension: ["0.2", "em"],
                whitespace: " ",
                dimension: ["0.2", "em"],
                whitespace: " ",
                dimension: ["0.2", ...],
                whitespace: " ",
                ...
              ]
            },
            prelude: [
              ident: "table",
              delim: ".",
              ident: "features",
              whitespace: " ",
              ident: "th",
              whitespace: " "
            ],
            top_level: true,
            value: [
              %Parser.Declaration{
                important: false,
                name: "background",
                value: [hash: "#00589f"]
              },
              %Parser.Declaration{
                important: false,
                name: "color",
                value: [hash: "#fff"]
              },
              %Parser.Declaration{
                important: false,
                name: "text-align",
                value: [ident: "left"]
              },
              %Parser.Declaration{
                important: false,
                name: "padding",
                value: [
                  dimension: ["0.2", "em"],
                  dimension: ["0.2", "em"],
                  dimension: ["0.2", "em"],
                  dimension: ["0.5", "em"]
                ]
              }
            ]
          },
          %Parser.QualifiedRule{
            block: %Parser.SimpleBlock{
              terminator: :rcurly,
              value: [
                whitespace: "\n\t\t",
                ident: "vertical-align",
                colon: ":",
                whitespace: " ",
                ident: "top",
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "border-bottom",
                colon: ":",
                whitespace: " ",
                dimension: ["1", "px"],
                whitespace: " ",
                ident: "solid",
                whitespace: " ",
                hash: "#ccc",
                semicolon: ";",
                whitespace: "\n\t\t",
                ident: "padding",
                colon: ":",
                whitespace: " ",
                dimension: ["0.3", "em"],
                whitespace: " ",
                dimension: ["0.3", "em"],
                whitespace: " ",
                dimension: ["0.3", "em"],
                whitespace: " ",
                dimension: [...],
                ...
              ]
            },
            prelude: [
              ident: "table",
              delim: ".",
              ident: "features",
              whitespace: " ",
              ident: "td",
              whitespace: " "
            ],
            top_level: true,
            value: [
              %Parser.Declaration{
                important: false,
                name: "vertical-align",
                value: [ident: "top"]
              },
              %Parser.Declaration{
                important: false,
                name: "border-bottom",
                value: [dimension: ["1", "px"], ident: "solid", hash: "#ccc"]
              },
              %Parser.Declaration{
                important: false,
                name: "padding",
                value: [
                  dimension: ["0.3", "em"],
                  dimension: ["0.3", "em"],
                  dimension: ["0.3", "em"],
                  dimension: ["0.7", "em"]
                ]
              }
            ]
          },
          %Parser.QualifiedRule{
            block: %Parser.SimpleBlock{
              terminator: :rcurly,
              value: [
                whitespace: "\n\t ",
                ident: "float",
                colon: ":",
                whitespace: " ",
                ident: "right",
                semicolon: ";",
                whitespace: "\n\t ",
                ident: "margin-top",
                colon: ":",
                whitespace: " ",
                dimension: ["-0.25", "em"],
                semicolon: ";",
                whitespace: "\n\t ",
                ident: "padding",
                colon: ":",
                whitespace: " ",
                dimension: ["0.5", "em"],
                whitespace: " ",
                dimension: ["1", "em"],
                whitespace: " ",
                dimension: ["0.5", "em"],
                whitespace: " ",
                number: "0",
                semicolon: ";",
                whitespace: "\n\t ",
                ident: "text-indent",
                ...
              ]
            },
            prelude: [
              delim: ".",
              ident: "atrisk",
              colon: ":",
              colon: ":",
              ident: "before",
              whitespace: " "
            ],
            top_level: true,
            value: [
              %Parser.Declaration{
                important: false,
                name: "float",
                value: [ident: "right"]
              },
              %Parser.Declaration{
                important: false,
                name: "margin-top",
                value: [dimension: ["-0.25", "em"]]
              },
              %Parser.Declaration{
                important: false,
                name: "padding",
                value: [
                  dimension: ["0.5", "em"],
                  dimension: ["1", "em"],
                  dimension: ["0.5", "em"],
                  number: "0"
                ]
              },
              %Parser.Declaration{
                important: false,
                name: "text-indent",
                value: [dimension: ["-0.9", "em"]]
              },
              %Parser.Declaration{
                important: false,
                name: "border",
                value: [dimension: ["1", "px"], ident: "solid"]
              },
              %Parser.Declaration{
                important: false,
                name: "content",
                value: [string: "'\\25C0    Not yet widely implemented'"]
              },
              %Parser.Declaration{
                important: false,
                name: "white-space",
                value: [ident: "pre"]
              },
              %Parser.Declaration{
                important: false,
                name: "font-size",
                value: [ident: "small"]
              },
              %Parser.Declaration{
                important: false,
                name: "background-color",
                value: [ident: "white"]
              },
              %Parser.Declaration{
                important: false,
                name: "color",
                value: [ident: "gray"]
              },
              %Parser.Declaration{
                important: false,
                name: "text-align",
                value: [ident: "center"]
              }
            ]
          },
          %Parser.QualifiedRule{
            block: %Parser.SimpleBlock{
              terminator: :rcurly,
              value: [
                whitespace: " ",
                ident: "content",
                colon: ":",
                ident: "none",
                whitespace: " "
              ]
            },
            prelude: [
              delim: ".",
              ident: "toc",
              whitespace: " ",
              delim: ".",
              ident: "atrisk",
              colon: ":",
              colon: ":",
              ident: "before",
              whitespace: " "
            ],
            top_level: true,
            value: [
              %Parser.Declaration{
                important: false,
                name: "content",
                value: [ident: "none"]
              }
            ]
          },
          %Parser.QualifiedRule{
            block: %Parser.SimpleBlock{
              terminator: :rcurly,
              value: [
                {:whitespace, "\n\t "},
                {:ident, "position"},
                {:colon, ":"},
                {:whitespace, " "},
                {:ident, "fixed"},
                {:semicolon, ";"},
                {:whitespace, "\n\t "},
                {:ident, "bottom"},
                {:colon, ":"},
                {:whitespace, " "},
                {:number, "0"},
                {:semicolon, ";"},
                {:whitespace, "\n\t "},
                {:ident, "right"},
                {:colon, ":"},
                {:whitespace, " "},
                {:number, "0"},
                {:semicolon, ";"},
                {:whitespace, "\n\t "},
                {:ident, "background"},
                {:colon, ":"},
                {:whitespace, " "},
                %Parser.Function{name: "rgba(", ...},
                {...},
                ...
              ]
            },
            prelude: [
              delim: ".",
              ident: "selected-text-file-an-issue",
              whitespace: " "
            ],
            top_level: true,
            value: [
              %Parser.Declaration{
                important: false,
                name: "position",
                value: [ident: "fixed"]
              },
              %Parser.Declaration{
                important: false,
                name: "bottom",
                value: [number: "0"]
              },
              %Parser.Declaration{
                important: false,
                name: "right",
                value: [number: "0"]
              },
              %Parser.Declaration{
                important: false,
                name: "background",
                value: [
                  %Parser.Function{
                    name: "rgba(",
                    value: [
                      number: "255",
                      comma: ",",
                      whitespace: " ",
                      number: "255",
                      comma: ",",
                      whitespace: " ",
                      number: "255",
                      comma: ",",
                      whitespace: " ",
                      number: "0.8"
                    ]
                  }
                ]
              },
              %Parser.Declaration{
                important: false,
                name: "font-size",
                value: [ident: "smaller"]
              },
              %Parser.Declaration{
                important: false,
                name: "padding",
                value: [dimension: ["4", "px"], dimension: ["10", "px"]]
              },
              %Parser.Declaration{
                important: false,
                name: "z-index",
                value: [number: "1"]
              },
              %Parser.Declaration{
                important: false,
                name: "text-decoration",
                value: [ident: "underline"]
              }
            ]
          },
          %Parser.AtRule{
            block: %Parser.SimpleBlock{
              terminator: :rcurly,
              value: [
                {:whitespace, "\n\t "},
                {:delim, "."},
                {:ident, "selected-text-file-an-issue"},
                {:whitespace, " "},
                %Parser.SimpleBlock{
                  terminator: :rcurly,
                  value: [
                    whitespace: " ",
                    ident: "left",
                    colon: ":",
                    whitespace: " ",
                    number: "0",
                    semicolon: ";",
                    whitespace: " ",
                    ident: "right",
                    colon: ":",
                    whitespace: " ",
                    ident: "auto",
                    semicolon: ";",
                    whitespace: " ",
                    ident: "text-align",
                    colon: ":",
                    whitespace: " ",
                    ...
                  ]
                },
                {:whitespace, "\n\t"}
              ]
            },
            name: "@media",
            prelude: [
              {:whitespace, " "},
              %Parser.SimpleBlock{
                terminator: :rparen,
                value: [
                  ident: "max-width",
                  colon: ":",
                  whitespace: " ",
                  dimension: ["767", "px"]
                ]
              },
              {:whitespace, " "}
            ],
            top_level: true,
            value: []
          }
        ]
      }}
    end
  end
end
