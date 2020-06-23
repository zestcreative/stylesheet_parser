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
    defstruct [:block]
  end

  defmodule SimpleBlock do
    defstruct [:block]
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
    {at_rule, tokens} = build_at_rule(tokens)
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
    tokens
    |> Stream.transform({[], []}, fn
      nil, _ ->
        {:halt, :premature_eof}
      {:semicolon, _}, {prelude, rest_tokens} ->
        {:halt, [{%AtRule{name: name, prelude: prelude}, rest_tokens}]}
      {:lcurly, _}, {prelude, rest_tokens} ->
        # {simple_block, rest_tokens} =
        #   build_simple_block(rest_tokens)
        simple_block = nil

        {:halt, [{%AtRule{
                    name: name, block: simple_block,
                    prelude: prelude
                  }, rest_tokens}]}
      token, {prelude, rest_tokens} ->
        {rest_tokens, {[token | prelude], rest_tokens}}
    end)
    |> Enum.to_list
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
    Enum.split_while(tokens, fn -> end )
  end
end
