defmodule StylesheetParser.DoctestTest do
  use ExUnit.Case, async: true

  doctest StylesheetParser.AtRule
  doctest StylesheetParser.ComplexSelector
  doctest StylesheetParser.CompoundSelector
  doctest StylesheetParser.Declaration
  doctest StylesheetParser.Function
  doctest StylesheetParser.ParseError
  doctest StylesheetParser.PseudoClass
  doctest StylesheetParser.QualifiedRule
  doctest StylesheetParser.SimpleBlock
  doctest StylesheetParser.SimpleSelector
  doctest StylesheetParser.Stylesheet
  doctest StylesheetParser.Selector.Parser
  doctest StylesheetParser.Syntax.Tokenizer
end
