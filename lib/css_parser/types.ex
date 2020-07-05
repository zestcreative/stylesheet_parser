defmodule CssParser.Stylesheet do
  defstruct [rules: []]

  defimpl String.Chars, for: __MODULE__ do
    defp token_to_string({:delim, "\\"}), do: "\\\n"
    defp token_to_string({_token, value}), do: Kernel.to_string(value)
    defp token_to_string(value), do: Kernel.to_string(value)

    def to_string(%{rules: rules}) do
      "#{Enum.map(rules, &token_to_string/1)}"
    end
  end
end

defmodule CssParser.AtRule do
  defstruct [:name, :block, value: [], prelude: [], top_level: false]

  defimpl String.Chars, for: __MODULE__ do
    defp token_to_string({:delim, "\\"}), do: "\\\n"
    defp token_to_string({_token, value}), do: Kernel.to_string(value)
    defp token_to_string(value), do: Kernel.to_string(value)

    def to_string(%{block: nil} = at_rule) do
      "#{at_rule.name}#{Enum.map(at_rule.prelude, &token_to_string/1)};"
    end
    def to_string(at_rule) do
      "#{at_rule.name}#{Enum.map(at_rule.prelude, &token_to_string/1)}#{token_to_string(at_rule.block)}\n"
    end
  end
end

defmodule CssParser.QualifiedRule do
  defstruct [:block, value: [], prelude: [], top_level: false]

  defimpl String.Chars, for: __MODULE__ do
    defp token_to_string({:delim, "\\"}), do: "\\\n"
    defp token_to_string({_token, value}), do: Kernel.to_string(value)
    defp token_to_string(value), do: Kernel.to_string(value)

    def to_string(%{block: nil} = qualified_rule) do
      "#{Enum.map(qualified_rule.prelude, &token_to_string/1)};"
    end
    def to_string(qualified_rule) do
      "#{Enum.map(qualified_rule.prelude, &token_to_string/1)} #{token_to_string(qualified_rule.block)}\n"
    end
  end
end

defmodule CssParser.Declaration do
  defstruct [:name, value: [], important: false]

  defimpl String.Chars, for: __MODULE__ do
    defp token_to_string({:delim, "\\"}), do: "\\\n"
    defp token_to_string({_token, value}), do: Kernel.to_string(value)
    defp token_to_string(value), do: Kernel.to_string(value)

    def to_string(%{important: true} = declaration) do
      "#{declaration.name}: #{Enum.map(declaration.value, &token_to_string/1)} !important;"
    end
    def to_string(declaration) do
      "#{declaration.name}: #{Enum.map(declaration.value, &token_to_string/1)};"
    end
  end
end

defmodule CssParser.Selector do
  defstruct [
    :combinator,
    :kind,
    :namespace,
    :type,
    classes: [],
    attributes: [],
    pseudo_classes: []
  ]

  defimpl String.Chars, for: __MODULE__ do
    def to_string(selectors) do
      selectors |> Enum.map(& Kernel.to_string(elem(&1, 1))) |> IO.inspect |> Enum.join()
    end
  end
end

defmodule CssParser.SimpleSelector do
  defstruct [:type, :value]

  defimpl String.Chars, for: __MODULE__ do
    def to_string(selectors) do
      selectors |> Enum.map(& Kernel.to_string(elem(&1, 1))) |> IO.inspect |> Enum.join()
    end
  end
end

defmodule CssParser.Selector.Combinator do
  defstruct [:kind, :selector]

  defimpl String.Chars, for: __MODULE__ do
    def to_string(%{type: :child}), do: ">"
    def to_string(%{type: :sibling}), do: "+"
    def to_string(%{type: :subsequent}), do: "~"
    def to_string(%{type: :column}), do: "||"
    def to_string(%{type: :descendant}), do: " "
  end
end

defmodule CssParser.CompoundSelector do
  defstruct [value: []]

  defimpl String.Chars, for: __MODULE__ do
    def to_string(selectors) do
      selectors |> Enum.map(& Kernel.to_string(elem(&1, 1))) |> IO.inspect |> Enum.join()
    end
  end
end

defmodule CssParser.ComplexSelector do
  defstruct [value: []]

  defimpl String.Chars, for: __MODULE__ do
    def to_string(selectors) do
      selectors |> Enum.map(& Kernel.to_string(elem(&1, 1))) |> IO.inspect |> Enum.join()
    end
  end
end

defmodule CssParser.Function do
  defstruct [:name, value: []]

  defimpl String.Chars, for: __MODULE__ do
    defp token_to_string({:delim, "\\"}), do: "\\\n"
    defp token_to_string({_token, value}), do: Kernel.to_string(value)
    defp token_to_string(value), do: Kernel.to_string(value)

    def to_string(function) do
      "#{function.name}#{Enum.map(function.value, &token_to_string/1)})"
    end
  end
end

defmodule CssParser.SimpleBlock do
  defstruct [:terminator, value: []]

  defimpl String.Chars, for: __MODULE__ do
    defp token_to_string({:delim, "\\"}), do: "\\\n"
    defp token_to_string({_token, value}), do: Kernel.to_string(value)
    defp token_to_string(value), do: Kernel.to_string(value)

    defp terminator_open(%{terminator: :rcurly}), do: "{"
    defp terminator_open(%{terminator: :rparen}), do: "( "
    defp terminator_open(%{terminator: :rbracket}), do: "["

    defp terminator_close(%{terminator: :rcurly}), do: "}"
    defp terminator_close(%{terminator: :rparen}), do: " )"
    defp terminator_close(%{terminator: :rbracket}), do: "]"

    def to_string(at_rule) do
      "#{terminator_open(at_rule)}#{Enum.map(at_rule.value, &token_to_string/1)}#{terminator_close(at_rule)}"
    end
  end
end
