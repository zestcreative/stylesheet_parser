defmodule CssTokenizer.Stylesheet do
  defstruct [rules: []]

  defmodule AtRule do
    defstruct [:name, :value, :block, prelude: []]
  end

  defmodule QualifiedRule do
    defstruct [:value, :block]
  end

  defmodule Declaration do
    defstruct [:name, :value, :important]
  end

  defmodule ComponentValue do
    defstruct [:block]
  end

  defmodule PreservedTokens do
    defstruct [:block]
  end

  defmodule Function do
    defstruct [:name, :value]
  end

  defmodule SimpleBlock do
    defstruct [value: []]
  end

  defmodule Dimension do
    defstruct [:name, :value, unit: ""]
  end

  defmodule Number do
    defstruct [:value, type: :number]
  end

  def parse(tokens) do
    %__MODULE__{rules: parse_rules(tokens, top_level: true)}
  end

  def parse_rules(tokens, top_level: top_level) do
    do_parse_rules(tokens, [], top_level)
  end

  def do_parse_rules([{:whitespace, _} | rest], acc) do
    do_parse_rules(rest, acc)
  end
  def do_parse_rules([], acc, _), do: acc

  def do_parse_rules([{:at_keyword, _} | _rest] = tokens, acc) do
    {:ok, at_rule, tokens} = build_at_rule(tokens)
    do_parse_rules(tokens, [at_rule | acc])
  end

  def do_parse_rules(tokens, acc) do
    {qualified_rule, rest} = build_qualified_rule(tokens)
    do_parse_rules(rest, [qualified_rule | acc])
  end


  @doc """
  # 5.4.2. Consume an at-rule

  To consume an at-rule:

  Consume the next input token. Create a new at-rule with its name set to the value of the current
  input token, its prelude initially set to an empty list, and its value initially set to nothing.

  Repeatedly consume the next input token:

  - `<semicolon-token>`: Return the at-rule.
  - `<EOF-token>`: This is a parse error. Return the at-rule.
  - `<{-token>`: Consume a simple block and assign it to the at-rule’s block. Return the at-rule.
  - anything else: Reconsume the current input token. Consume a component value. Append the returned
    value to the at-rule’s prelude.
  """
  def build_at_rule([{:at_keyword, name} | tokens]) do
    Enum.reduce_while(tokens, {:ok, %AtRule{name: name}, tokens}, fn
      nil, _ ->
        {:halt, {:error, :premature_eof}}

      _token, {:ok, at_rule, [_ | rest], 1} -> {:cont, {:ok, at_rule, rest}}
      _token, {:ok, at_rule, [_ | rest], i} when i > 0 ->
        # we're inside a component value, skip it
        {:cont, {:ok, at_rule, rest, i - 1}}

      {:semicolon, _}, {:ok, at_rule, [_ | rest]} ->
        {:halt, {:ok, %{at_rule | prelude: Enum.reverse(at_rule.prelude)}, rest}}

      {:lcurly, _}, {:ok, at_rule, tokens} ->
        IO.inspect at_rule, label: "AT RULE"
        IO.inspect tokens, label: "TOKENS"
        {:ok, simple_block, rest} = build_simple_block(tokens)
        {:halt, {:ok, %{at_rule | prelude: Enum.reverse(at_rule.prelude), block: simple_block}, rest}}

      _token, {:ok, at_rule, [_ | rest_tokens] = tokens} ->
        {:ok, value, rest} = build_component_value(tokens)
        {:cont, {:ok, %{at_rule | prelude: [value | at_rule.prelude]}, rest_tokens, length(tokens) - length(rest)}}
    end)
  end

  @doc """
  5.4.3. Consume a qualified rule
  To consume a qualified rule:

  Create a new qualified rule with its prelude initially set to an empty list, and its value
  initially set to nothing.

  Repeatedly consume the next input token:

  - `<EOF-token>`:  This is a parse error. Return nothing.
  - `<{-token>`: Consume a simple block and assign it to the qualified rule’s block. Return the
    qualified rule.
  - anything else: Reconsume the current input token. Consume a component value. Append the returned
    value to the qualified rule’s prelude.
  """
  def build_qualified_rule(tokens) do
  end

  def build_simple_block([{:lcurly, _} | tokens]) do
    Enum.reduce_while(tokens, {:ok, %SimpleBlock{}, tokens}, fn
      nil, _ ->
        {:halt, {:error, :premature_eof}}

      _token, {:ok, simple_block, [_ | rest], 1} ->
        {:cont, {:ok, simple_block, rest}}

      _token, {:ok, simple_block, [_ | rest], i} when i > 0 ->
        # we're inside a component value, skip it
        {:cont, {:ok, simple_block, rest, i - 1}}

      {:rcurly, _}, {:ok, simple_block, [_ | rest]} ->
        {:halt, {:ok, %{simple_block | value: Enum.reverse(simple_block.value)}, rest}}

      _token, {:ok, simple_block, [_ | rest_tokens] = tokens} ->
        {:ok, component_value, rest} = build_component_value(tokens)
        {:cont, {:ok, %{simple_block | value: [component_value | simple_block.value]}, rest_tokens, length(tokens) - length(rest)}}
    end)
  end

  def build_simple_block([{:lbracket, _} | tokens]) do
    Enum.reduce_while(tokens, {:ok, %SimpleBlock{}, tokens}, fn
      nil, _ ->
        {:halt, {:error, :premature_eof}}

      _token, {:ok, simple_block, [_ | rest], 1} ->
        {:cont, {:ok, simple_block, rest}}

      _token, {:ok, simple_block, [_ | rest], i} when i > 0 ->
        # we're inside a component value, skip it
        {:cont, {:ok, simple_block, rest, i - 1}}

      {:rbracket, _}, {:ok, simple_block, [_ | rest]} ->
        {:halt, {:ok, %{simple_block | value: Enum.reverse(simple_block.value)}, rest}}

      _token, {:ok, simple_block, [_ | rest_tokens] = tokens} ->
        {:ok, component_value, rest} = build_component_value(tokens)
        {:cont, {:ok, %{simple_block | value: [component_value | simple_block.value]}, rest_tokens, length(tokens) - length(rest)}}
    end)
  end

  def build_simple_block([{:lparen, _} | tokens]) do
    Enum.reduce_while(tokens, {:ok, %SimpleBlock{}, tokens}, fn
      nil, _ ->
        {:halt, {:error, :premature_eof}}

      _token, {:ok, simple_block, [_ | rest], 1} ->
        {:cont, {:ok, simple_block, rest}}

      _token, {:ok, simple_block, [_ | rest], i} when i > 0 ->
        # we're inside a component value, skip it
        {:cont, {:ok, simple_block, rest, i - 1}}

      {:rparen, _}, {:ok, simple_block, [_ | rest]} ->
        {:halt, {:ok, %{simple_block | value: Enum.reverse(simple_block.value)}, rest}}

      _token, {:ok, simple_block, [_ | rest_tokens] = tokens} ->
        {:ok, component_value, rest} = build_component_value(tokens)
        {:cont, {:ok, %{simple_block | value: [component_value | simple_block.value]}, rest_tokens, length(tokens) - length(rest)}}
    end)
  end

  @doc """
  # 5.4.8. Consume a function
  Note: This algorithm assumes that the current input token has already been checked to be a
  <function-token>.

  To consume a function:

  Create a function with a name equal to the value of the current input token, and with a value
  which is initially an empty list. Repeatedly consume the next input token and process it as
  follows:

  - `<)-token>`: Return the function.
  - `<EOF-token>`: This is a parse error. Return the function.
  - anything else: Reconsume the current input token. Consume a component value and append the
    returned value to the function’s value.
  """
  def build_function([{:lparen, name} | tokens]) do
    Enum.reduce_while(tokens, {:ok, %Function{name: name}, tokens}, fn
      nil, _ ->
        {:halt, {:error, :premature_eof}}

      _token, {:ok, function, [_ | rest], 1} ->
        {:cont, {:ok, function, rest}}

      _token, {:ok, function, [_ | rest], i} when i > 0 ->
        # we're inside a component value, skip it
        {:cont, {:ok, function, rest, i - 1}}

      {:rparen, _}, {:ok, function, [_ | rest]} ->
        {:halt, {:ok, %{function | value: Enum.reverse(function.value)}, rest}}

      _token, {:ok, function, [_ | rest_tokens] = tokens} ->
        {:ok, component_value, rest} = build_component_value(tokens)
        {:cont, {:ok, %{function | value: [component_value | function.value]}, rest_tokens, length(tokens) - length(rest)}}
    end)
  end

  @doc """
  # 5.4.6. Consume a component value

  To consume a component value:

  - If the current input token is a <{-token>, <[-token>, or <(-token>, consume a simple block and
    return it.
  - Otherwise, if the current input token is a <function-token>, consume a function and return it.
  - Otherwise, return the current input token.
  """
  def build_component_value([{:lcurly, _} | _] = tokens), do: build_simple_block(tokens)
  def build_component_value([{:lbracket, _} | _] = tokens), do: build_simple_block(tokens)
  def build_component_value([{:lparen, _} | _] = tokens), do: build_simple_block(tokens)
  def build_component_value([{:function, _} | _] = tokens), do: build_function(tokens)
  def build_component_value([token | rest]), do: {:ok, token, rest}
  def build_component_value([]), do: {:ok, nil, []}
end
