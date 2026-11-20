defmodule CssParser.Serialize do
  @moduledoc false
  # CSS text for parsed values. Comments are gone, and whitespace inside rules is normalized, so
  # serializing what a stylesheet parses to parses to the same rules again.

  alias CssParser.{Function, SimpleBlock, SimpleSelector, CompoundSelector, ComplexSelector}

  def values(values), do: Enum.map_join(values, &value/1)

  def value({:dimension, [number, unit]}), do: number <> unit
  def value({:percentage, number}), do: number <> "%"
  def value({_type, value}), do: Kernel.to_string(value)
  def value(other), do: Kernel.to_string(other)

  def selectors([%{} | _] = selectors), do: Enum.map_join(selectors, ", ", &selector/1)
  def selectors(prelude), do: values(prelude)

  def selector(%SimpleSelector{type: type, value: value}), do: part({type, value})

  def selector(%CompoundSelector{value: parts}),
    do: parts |> List.flatten() |> Enum.map_join(&part/1)

  def selector(%ComplexSelector{value: [first | rest]}),
    do: selector(first) <> (rest |> List.flatten() |> Enum.map_join(&part/1))

  def selector(%Function{} = function), do: Kernel.to_string(function)

  defp part({:pseudo_class, %Function{} = function}), do: ":" <> Kernel.to_string(function)
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

  def block(%SimpleBlock{} = block), do: " " <> Kernel.to_string(block)
  def block(nil), do: ";"
  def block(contents), do: " { " <> Enum.map_join(contents, " ", &Kernel.to_string/1) <> " }"
end

defmodule CssParser.Stylesheet do
  @moduledoc "A parsed stylesheet: its rules, in order."
  defstruct rules: []

  defimpl String.Chars do
    def to_string(%{rules: rules}), do: Enum.map_join(rules, "\n", &Kernel.to_string/1)
  end
end

defmodule CssParser.AtRule do
  @moduledoc """
  An at-rule, such as `@media`: its `name` with its `@`, its `prelude` of component values, and its
  `block`: nil for one that ends with `;`, its rules for a rule-list at-rule such as `@media`, its
  declarations for another, or a `CssParser.SimpleBlock` when those don't parse.
  """
  defstruct [:name, :block, :line, :column, prelude: [], top_level: false]

  defimpl String.Chars do
    alias CssParser.Serialize

    def to_string(%{name: name, prelude: [], block: block}), do: name <> Serialize.block(block)

    def to_string(%{name: name, prelude: prelude, block: block}),
      do: "#{name} #{Serialize.values(prelude)}#{Serialize.block(block)}"
  end
end

defmodule CssParser.QualifiedRule do
  @moduledoc """
  A style rule: its `prelude`, the selector list (or its component values when they aren't
  selectors, such as a keyframe's `50%`), and its `block` of declarations.
  """
  defstruct [:line, :column, block: [], prelude: [], top_level: false]

  defimpl String.Chars do
    alias CssParser.Serialize

    def to_string(%{prelude: prelude, block: block}),
      do: Serialize.selectors(prelude) <> Serialize.block(block)
  end
end

defmodule CssParser.Declaration do
  @moduledoc "A declaration, `name: value`, its value component values without whitespace at either end."
  defstruct [:name, :line, :column, value: [], important: false]

  defimpl String.Chars do
    alias CssParser.Serialize

    def to_string(%{important: true} = declaration),
      do: "#{declaration.name}: #{Serialize.values(declaration.value)} !important;"

    def to_string(declaration), do: "#{declaration.name}: #{Serialize.values(declaration.value)};"
  end
end

defmodule CssParser.SimpleSelector do
  @moduledoc "One selector, such as `{:class, \".card\"}` as `type: :class, value: \".card\"`."
  defstruct [:type, :value]

  defimpl String.Chars do
    def to_string(selector), do: CssParser.Serialize.selector(selector)
  end
end

defmodule CssParser.CompoundSelector do
  @moduledoc "Selectors that apply to one element together, such as `span.note`, as `{type, value}` parts."
  defstruct value: []

  defimpl String.Chars do
    def to_string(selector), do: CssParser.Serialize.selector(selector)
  end
end

defmodule CssParser.ComplexSelector do
  @moduledoc "Compound selectors joined by combinators, such as `.card > span`."
  defstruct value: []

  defimpl String.Chars do
    def to_string(selector), do: CssParser.Serialize.selector(selector)
  end
end

defmodule CssParser.Function do
  @moduledoc "A function, such as `var(--space-s)`: its `name` without the `(`, and its component values."
  defstruct [:name, :line, :column, value: []]

  defimpl String.Chars do
    def to_string(function), do: "#{function.name}(#{CssParser.Serialize.values(function.value)})"
  end
end

defmodule CssParser.SimpleBlock do
  @moduledoc "A block in `{}`, `[]` or `()`, named by the token that ends it, and its component values."
  defstruct [:terminator, :line, :column, value: []]

  defimpl String.Chars do
    def to_string(%{terminator: terminator, value: value}) do
      {open, close} = %{rcurly: {"{", "}"}, rbracket: {"[", "]"}, rparen: {"(", ")"}}[terminator]
      open <> CssParser.Serialize.values(value) <> close
    end
  end
end
