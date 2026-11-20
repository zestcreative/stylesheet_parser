defmodule StylesheetParser.Serialize do
  @moduledoc false
  # CSS text for parsed values. Comments are gone, and whitespace inside rules is normalized, so
  # serializing what a stylesheet parses to parses to the same rules again.

  alias StylesheetParser.{Function, PseudoClass, SimpleBlock, SimpleSelector}
  alias StylesheetParser.{CompoundSelector, ComplexSelector}
  alias StylesheetParser.Syntax.Tokenizer

  # Component values written next to each other, with a `/**/` between two that would read back
  # as one token otherwise, such as `1px` and `2px` that a comment separated.
  def values([]), do: ""

  def values([first | rest]) do
    {iodata, _last} =
      Enum.reduce(rest, {[value(first)], first}, fn current, {iodata, previous} ->
        {[iodata, separator(previous, current), value(current)], current}
      end)

    IO.iodata_to_binary(iodata)
  end

  defp separator(previous, current) do
    case {last_text(previous), first_text(current)} do
      {:none, _} -> ""
      {_, :none} -> ""
      {left, right} -> if reads_back?(left, right), do: "", else: "/**/"
    end
  end

  # The text at either end of a component value that a neighbour could run into. Whitespace and
  # closing brackets end tokens on their own.
  defp last_text({:whitespace, _}), do: :none
  defp last_text({_type, _value} = token), do: value(token)
  defp last_text(%{}), do: :none

  defp first_text({:whitespace, _}), do: :none
  defp first_text({_type, _value} = token), do: value(token)
  defp first_text(%Function{name: name}), do: name <> "("
  defp first_text(%SimpleBlock{} = block), do: block |> Kernel.to_string() |> String.first()

  defp reads_back?(left, right) do
    case Tokenizer.consume(left <> right) do
      {:ok, [{type1, value1, _}, {type2, value2, _}], "", _, _, _} ->
        [value({type1, value1}), value({type2, value2})] == [left, right]

      _ ->
        false
    end
  end

  def value({:dimension, [number, unit]}), do: number <> unit
  def value({:percentage, number}), do: number <> "%"
  def value({_type, value}), do: Kernel.to_string(value)
  def value(other), do: Kernel.to_string(other)

  def selectors([%{} | _] = selectors), do: Enum.map_join(selectors, ", ", &selector/1)
  def selectors(prelude), do: values(prelude)

  def selector(%SimpleSelector{type: type, value: value}), do: part({type, value})

  def selector(%CompoundSelector{value: parts}),
    do: parts |> List.flatten() |> Enum.map_join(&part/1)

  # A relative selector starts with its combinator, as `> a`.
  def selector(%ComplexSelector{value: parts}),
    do: parts |> List.flatten() |> Enum.map_join(&part/1) |> String.trim_leading()

  def selector(%Function{} = function), do: Kernel.to_string(function)

  defp part({:pseudo_class, %Function{} = function}), do: ":" <> Kernel.to_string(function)
  defp part({:pseudo_class, %PseudoClass{} = pseudo_class}), do: ":" <> pseudo_class(pseudo_class)
  defp part({:pseudo_element, %Function{} = function}), do: "::" <> Kernel.to_string(function)
  defp part({:descendant_combinator, _}), do: " "

  defp part({combinator, value})
       when combinator in [
              :child_combinator,
              :sibling_combinator,
              :subsequent_combinator,
              :column_combinator
            ],
       do: " #{value} "

  defp part({_type, value}) when is_binary(value), do: value
  defp part(%{} = selector), do: selector(selector)

  def pseudo_class(%PseudoClass{name: name, an_b: nil, selectors: selectors}),
    do: "#{name}(#{selectors(selectors)})"

  def pseudo_class(%PseudoClass{name: name, an_b: an_b, selectors: []}),
    do: "#{name}(#{an_b(an_b)})"

  def pseudo_class(%PseudoClass{name: name, an_b: an_b, selectors: selectors}),
    do: "#{name}(#{an_b(an_b)} of #{selectors(selectors)})"

  # As CSSOM serializes An+B: `odd` as `2n+1`.
  defp an_b({0, b}), do: Integer.to_string(b)
  defp an_b({a, b}), do: n(a) <> signed(b)

  defp n(1), do: "n"
  defp n(-1), do: "-n"
  defp n(a), do: "#{a}n"

  defp signed(0), do: ""
  defp signed(b) when b > 0, do: "+#{b}"
  defp signed(b), do: Integer.to_string(b)

  def block(nil), do: ";"
  def block(contents), do: " { " <> Enum.map_join(contents, " ", &Kernel.to_string/1) <> " }"
end
