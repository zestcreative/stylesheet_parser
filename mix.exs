defmodule StylesheetParser.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/zestcreative/stylesheet_parser"

  def project do
    [
      app: :stylesheet_parser,
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "StylesheetParser",
      description:
        "A CSS Syntax Level 3 tokenizer and parser, with CSS Nesting and a Selectors Level 4 selector parser.",
      source_url: @source_url,
      package: package(),
      docs: docs()
    ]
  end

  def application, do: [extra_applications: [:logger]]

  defp deps do
    [
      {:nimble_parsec, "~> 1.4", runtime: false, only: [:test, :dev]},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md"
      },
      files: ~w(lib mix.exs README.md LICENSE CHANGELOG.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md"],
      source_ref: "v#{@version}",
      groups_for_modules: [
        Parsing: [
          StylesheetParser,
          StylesheetParser.Syntax.Parser,
          StylesheetParser.Syntax.Tokenizer,
          StylesheetParser.Selector.Parser,
          StylesheetParser.ParseError
        ],
        Rules: [
          StylesheetParser.Stylesheet,
          StylesheetParser.AtRule,
          StylesheetParser.QualifiedRule,
          StylesheetParser.Declaration,
          StylesheetParser.Function,
          StylesheetParser.SimpleBlock
        ],
        Selectors: [
          StylesheetParser.SimpleSelector,
          StylesheetParser.CompoundSelector,
          StylesheetParser.ComplexSelector,
          StylesheetParser.PseudoClass
        ]
      ]
    ]
  end
end
