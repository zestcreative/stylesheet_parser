defmodule CssParser.Syntax.Parser do
  @moduledoc """
  The parsing algorithms of [CSS Syntax Level 3](https://www.w3.org/TR/css-syntax-3/#parsing),
  over the tokenizer's tokens, `{type, value, {line, column}}`.

  Rules, declarations, functions and simple blocks carry the `line` and `column` where they start.
  The component values inside them (a declaration's value, an at-rule's prelude, a block's or a
  function's value) are `{type, value}`, without positions.

  A qualified rule's prelude is its selector list (`CssParser.Selector.Parser`) when the selectors
  take the whole prelude, and its component values otherwise, such as a keyframe's `50%`. Its
  block is its declarations. An at-rule whose block holds rules (`@media`, `@supports` and the
  others in `rule_list_at_rules/0`) has its rules as its block; any other at-rule with a block
  has its declarations, or the `CssParser.SimpleBlock` when they don't parse.

  Malformed input is `{:error, %CssParser.Syntax.Parser.ParseError{}}`, with the line and column
  where it is: an unclosed block or function, a qualified rule with no block, a declaration with
  no colon, or anything else where a declaration belongs.
  """

  alias CssParser.Selector.Parser, as: Selector
  alias CssParser.{AtRule, Declaration, QualifiedRule, Function, SimpleBlock, Stylesheet}

  defmodule ParseError do
    defexception [:message, :line, :column]

    @impl true
    def message(%{message: message, line: nil}), do: message

    def message(%{message: message, line: line, column: column}),
      do: "#{line}:#{column}: #{message}"
  end

  @rule_list_at_rules ~w(@media @supports @layer @container @scope @starting-style @document @keyframes)

  @doc "The at-rules whose block is a list of rules."
  def rule_list_at_rules, do: @rule_list_at_rules

  @doc """
  # 5.3.2. Parse a stylesheet

  1. Create a new stylesheet.
  2. Consume a list of rules from the stream of tokens, with the top-level flag set. Let the return value be rules.
  3. Assign rules to the stylesheet’s value.
  4. Return the stylesheet.
  """
  def parse_stylesheet(tokens) do
    with {:ok, rules} <- parse_rules(tokens, top_level: true) do
      {:ok, %Stylesheet{rules: rules}}
    end
  end

  @doc """
  # 5.3.3. Parse a list of rules

  1. Consume a list of rules from the stream of tokens, with the top-level flag unset.
  2. Return the returned list.
  """
  def parse_rules(tokens, opts \\ []), do: consume_rules(tokens, [], opts[:top_level] || false)

  # 5.4.1. Consume a list of rules
  defp consume_rules([], rules, _top_level), do: {:ok, Enum.reverse(rules)}

  defp consume_rules([{:whitespace, _, _} | rest], rules, top_level),
    do: consume_rules(rest, rules, top_level)

  defp consume_rules([{cdo_or_cdc, _, _} | rest], rules, true) when cdo_or_cdc in [:cdo, :cdc],
    do: consume_rules(rest, rules, true)

  defp consume_rules([{:at_keyword, _, _} | _] = tokens, rules, top_level) do
    with {:ok, at_rule, rest} <- build_at_rule(tokens, top_level: top_level) do
      consume_rules(rest, [at_rule | rules], top_level)
    end
  end

  defp consume_rules(tokens, rules, top_level) do
    with {:ok, qualified_rule, rest} <- build_qualified_rule(tokens, top_level: top_level) do
      consume_rules(rest, [qualified_rule | rules], top_level)
    end
  end

  @doc """
  # 5.3.4. Parse a rule

  1. While the next input token is a `<whitespace-token>`, consume the next input token.
  2. If the next input token is an `<EOF-token>`, return a syntax error.
     Otherwise, if the next input token is an `<at-keyword-token>`, consume an at-rule, and let rule be the return value.
     Otherwise, consume a qualified rule and let rule be the return value. If nothing was returned, return a syntax error.
  3. While the next input token is a `<whitespace-token>`, consume the next input token.
  4. If the next input token is an `<EOF-token>`, return rule. Otherwise, return a syntax error.
  """
  def parse_rule(tokens, opts \\ []) do
    top_level = opts[:top_level] || false

    with [first | _] = tokens <- skip_whitespace(tokens),
         {:ok, rule, rest} <- build_rule(first, tokens, top_level),
         [] <- skip_whitespace(rest) do
      {:ok, rule}
    else
      [] -> error("expected a rule", nil)
      [extra | _] -> error("expected one rule", extra)
      {:error, _} = error -> error
    end
  end

  defp build_rule({:at_keyword, _, _}, tokens, top_level),
    do: build_at_rule(tokens, top_level: top_level)

  defp build_rule(_first, tokens, top_level),
    do: build_qualified_rule(tokens, top_level: top_level)

  @doc """
  # 5.3.5. Parse a declaration

  1. While the next input token is a `<whitespace-token>`, consume the next input token.
  2. If the next input token is not an `<ident-token>`, return a syntax error.
  3. Consume a declaration. If anything was returned, return it. Otherwise, return a syntax error.
  """
  def parse_declaration(tokens) do
    case skip_whitespace(tokens) do
      [{:ident, _, _} | _] = tokens ->
        # A declaration written on its own may end with its `;`.
        with {:ok, components} <- consume_components(tokens) do
          components |> trim_whitespace() |> drop_semicolon() |> build_declaration()
        end

      [other | _] ->
        error("expected a declaration", other)

      [] ->
        error("expected a declaration", nil)
    end
  end

  @doc """
  # 5.3.6. Parse a list of declarations

  **Note** Despite the name, this actually parses a mixed list of declarations and at-rules, as
  CSS 2.1 does for @page.
  """
  def parse_declarations(tokens) do
    with {:ok, components} <- consume_components(tokens) do
      consume_declarations(components, [])
    end
  end

  # 5.4.4. Consume a list of declarations, over component values.
  defp consume_declarations([], declarations), do: {:ok, Enum.reverse(declarations)}

  defp consume_declarations([{skip, _, _} | rest], declarations)
       when skip in [:whitespace, :semicolon],
       do: consume_declarations(rest, declarations)

  defp consume_declarations([{:at_keyword, _, _} | _] = components, declarations) do
    with {:ok, at_rule, rest} <- build_at_rule(components) do
      consume_declarations(rest, [at_rule | declarations])
    end
  end

  defp consume_declarations([{:ident, _, _} | _] = components, declarations) do
    {declaration, rest} = Enum.split_while(components, &(not match?({:semicolon, _, _}, &1)))

    with {:ok, declaration} <- build_declaration(declaration) do
      consume_declarations(rest, [declaration | declarations])
    end
  end

  defp consume_declarations([other | _], _declarations),
    do: error("expected a declaration", other)

  @doc """
  # 5.3.7. Parse a component value

  1. While the next input token is a `<whitespace-token>`, consume the next input token.
  2. If the next input token is an `<EOF-token>`, return a syntax error.
  3. Consume a component value and let value be the return value.
  4. While the next input token is a `<whitespace-token>`, consume the next input token.
  5. If the next input token is an `<EOF-token>`, return value. Otherwise, return a syntax error.
  """
  def parse_component_value(tokens) do
    with [_ | _] = tokens <- skip_whitespace(tokens),
         {:ok, value, rest} <- build_component_value(tokens),
         [] <- skip_whitespace(rest) do
      {:ok, plain(value)}
    else
      [] -> error("expected a component value", nil)
      [extra | _] -> error("expected one component value", extra)
      {:error, _} = error -> error
    end
  end

  @doc """
  # 5.3.8. Parse a list of component values

  1. Repeatedly consume a component value until an `<EOF-token>` is returned, appending the
     returned values (except the final `<EOF-token>`) into a list. Return the list.
  """
  def parse_component_values(tokens) do
    with {:ok, components} <- consume_components(tokens) do
      {:ok, Enum.map(components, &plain/1)}
    end
  end

  @doc """
  # 5.4.2. Consume an at-rule

  Consume the next input token. Create a new at-rule with its name set to the value of the current
  input token, its prelude initially set to an empty list, and its value initially set to nothing.

  Repeatedly consume the next input token:

  - `<semicolon-token>` - Return the at-rule.
  - `<EOF-token>` - This is a parse error. Return the at-rule.
  - `<{-token>` - Consume a simple block and assign it to the at-rule’s block. Return the at-rule.
  - anything else - Reconsume the current input token. Consume a component value. Append the
    returned value to the at-rule’s prelude.
  """
  def build_at_rule([{:at_keyword, name, {line, column}} | tokens], opts \\ []) do
    at_rule = %AtRule{
      name: name,
      line: line,
      column: column,
      top_level: opts[:top_level] || false
    }

    consume_at_rule(tokens, at_rule, [])
  end

  defp consume_at_rule([], at_rule, prelude), do: {:ok, finish_at_rule(at_rule, prelude), []}

  defp consume_at_rule([{:semicolon, _, _} | rest], at_rule, prelude),
    do: {:ok, finish_at_rule(at_rule, prelude), rest}

  defp consume_at_rule([block | rest], at_rule, prelude)
       when is_struct(block, SimpleBlock) and block.terminator == :rcurly,
       do: at_rule_block(block, rest, at_rule, prelude)

  defp consume_at_rule([{:lcurly, _, _} | _] = tokens, at_rule, prelude) do
    with {:ok, block, rest} <- build_simple_block(tokens) do
      at_rule_block(block, rest, at_rule, prelude)
    end
  end

  defp consume_at_rule(tokens, at_rule, prelude) do
    with {:ok, value, rest} <- build_component_value(tokens) do
      consume_at_rule(rest, at_rule, [value | prelude])
    end
  end

  defp at_rule_block(
         %SimpleBlock{value: value} = block,
         rest,
         %AtRule{name: name} = at_rule,
         prelude
       ) do
    contents =
      if String.downcase(name) in @rule_list_at_rules,
        do: parse_rules(value),
        else: with({:error, _} <- consume_declarations(value, []), do: {:ok, plain(block)})

    with {:ok, contents} <- contents do
      {:ok, %{finish_at_rule(at_rule, prelude) | block: contents}, rest}
    end
  end

  defp finish_at_rule(at_rule, prelude),
    do: %{at_rule | prelude: prelude |> Enum.reverse() |> trim_whitespace() |> Enum.map(&plain/1)}

  @doc """
  # 5.4.3. Consume a qualified rule

  Create a new qualified rule with its prelude initially set to an empty list, and its value
  initially set to nothing.

  Repeatedly consume the next input token:

  - `<EOF-token>` - This is a parse error. Return nothing.
  - `<{-token>` - Consume a simple block and assign it to the qualified rule’s block. Return the
    qualified rule.
  - anything else - Reconsume the current input token. Consume a component value. Append the
    returned value to the qualified rule’s prelude.
  """
  def build_qualified_rule(tokens, opts \\ []) do
    {line, column} = position(hd(tokens))
    rule = %QualifiedRule{line: line, column: column, top_level: opts[:top_level] || false}
    consume_qualified_rule(tokens, rule, [])
  end

  defp consume_qualified_rule([], rule, _prelude),
    do: error("expected { after the selector", {nil, nil, {rule.line, rule.column}})

  defp consume_qualified_rule([block | rest], rule, prelude)
       when is_struct(block, SimpleBlock) and block.terminator == :rcurly,
       do: qualified_rule_block(block, rest, rule, prelude)

  defp consume_qualified_rule([{:lcurly, _, _} | _] = tokens, rule, prelude) do
    with {:ok, block, rest} <- build_simple_block(tokens) do
      qualified_rule_block(block, rest, rule, prelude)
    end
  end

  defp consume_qualified_rule(tokens, rule, prelude) do
    with {:ok, value, rest} <- build_component_value(tokens) do
      consume_qualified_rule(rest, rule, [value | prelude])
    end
  end

  defp qualified_rule_block(%SimpleBlock{value: value}, rest, rule, prelude) do
    prelude = prelude |> Enum.reverse() |> trim_whitespace() |> Enum.map(&plain/1)

    with {:ok, declarations} <- consume_declarations(value, []) do
      {:ok, %{rule | prelude: selectors(prelude), block: declarations}, rest}
    end
  end

  # The selector list when it takes the whole prelude, else the component values.
  defp selectors(prelude) do
    case Selector.selector_list(prelude) do
      {[_ | _] = selectors, []} -> selectors
      _ -> prelude
    end
  end

  @doc """
  # 5.4.7. Consume a simple block

  The ending token is the mirror variant of the current input token. Repeatedly consume the next
  input token and process it as follows:

  - ending token - Return the block.
  - `<EOF-token>` - This is a parse error. Return the block.
  - anything else - Reconsume the current input token. Consume a component value and append it to
    the value of the block.

  An unclosed block is an error here, at the block's opening token.
  """
  def build_simple_block([{opening, _, {line, column}} | tokens])
      when opening in [:lcurly, :lbracket, :lparen] do
    terminator = %{lcurly: :rcurly, lbracket: :rbracket, lparen: :rparen}[opening]

    consume_simple_block(
      tokens,
      %SimpleBlock{terminator: terminator, line: line, column: column},
      []
    )
  end

  defp consume_simple_block([], block, _value),
    do: error("unclosed #{opening(block.terminator)}", {nil, nil, {block.line, block.column}})

  defp consume_simple_block(
         [{terminator, _, _} | rest],
         %{terminator: terminator} = block,
         value
       ),
       do: {:ok, %{block | value: Enum.reverse(value)}, rest}

  defp consume_simple_block(tokens, block, value) do
    with {:ok, component, rest} <- build_component_value(tokens) do
      consume_simple_block(rest, block, [component | value])
    end
  end

  defp opening(:rcurly), do: "{"
  defp opening(:rbracket), do: "["
  defp opening(:rparen), do: "("

  @doc """
  # 5.4.8. Consume a function

  Create a function with a name equal to the value of the current input token (without its `(`),
  and with a value which is initially an empty list. Repeatedly consume the next input token:

  - `<)-token>` - Return the function.
  - `<EOF-token>` - This is a parse error. Return the function.
  - anything else - Reconsume the current input token. Consume a component value and append the
    returned value to the function’s value.

  An unclosed function is an error here, at its name.
  """
  def build_function([{:function, name, {line, column}} | tokens]) do
    consume_function(
      tokens,
      %Function{name: String.trim_trailing(name, "("), line: line, column: column},
      []
    )
  end

  defp consume_function([], function, _value),
    do: error("unclosed #{function.name}(", {nil, nil, {function.line, function.column}})

  defp consume_function([{:rparen, _, _} | rest], function, value),
    do: {:ok, %{function | value: Enum.reverse(value)}, rest}

  defp consume_function(tokens, function, value) do
    with {:ok, component, rest} <- build_component_value(tokens) do
      consume_function(rest, function, [component | value])
    end
  end

  @doc """
  # 5.4.5. Consume a declaration

  Over component values that start with an `<ident-token>`:

  1. While the next input token is a `<whitespace-token>`, consume the next input token.
  2. If the next input token is anything other than a `<colon-token>`, this is a parse error.
     Return nothing. Otherwise, consume the next input token.
  3. While the next input token is a `<whitespace-token>`, consume the next input token.
  4. As long as the next input token is anything other than an `<EOF-token>`, consume a component
     value and append it to the declaration’s value.
  5. If the last two non-`<whitespace-token>`s in the declaration’s value are a `<delim-token>`
     with the value "!" followed by an `<ident-token>` with a value that is an ASCII
     case-insensitive match for "important", remove them from the declaration’s value and set the
     declaration’s important flag to true.
  6. While the last token in the declaration’s value is a `<whitespace-token>`, remove that token.
  7. Return the declaration.
  """
  def build_declaration([{:ident, name, {line, column}} = ident | components]) do
    case skip_whitespace(components) do
      [{:colon, _, _} | value] ->
        {value, important} = value |> trim_whitespace() |> important()

        {:ok,
         %Declaration{
           name: name,
           value: Enum.map(value, &plain/1),
           important: important,
           line: line,
           column: column
         }}

      _ ->
        error("expected : after #{name}", ident)
    end
  end

  defp important(value) do
    case value |> Enum.reverse() |> skip_whitespace() do
      [{:ident, word, _} | before] ->
        case skip_whitespace(before) do
          [{:delim, "!", _} | before] ->
            if String.downcase(word) == "important",
              do: {before |> Enum.reverse() |> trim_whitespace(), true},
              else: {value, false}

          _ ->
            {value, false}
        end

      _ ->
        {value, false}
    end
  end

  @doc """
  # 5.4.6. Consume a component value

  - If the current input token is a `<{-token>`, `<[-token>`, or `<(-token>`, consume a simple
    block and return it.
  - Otherwise, if the current input token is a `<function-token>`, consume a function and return it.
  - Otherwise, return the current input token.
  """
  def build_component_value([{opening, _, _} | _] = tokens)
      when opening in [:lcurly, :lbracket, :lparen],
      do: build_simple_block(tokens)

  def build_component_value([{:function, _, _} | _] = tokens), do: build_function(tokens)
  def build_component_value([component | rest]), do: {:ok, component, rest}

  defp consume_components(tokens, components \\ [])
  defp consume_components([], components), do: {:ok, Enum.reverse(components)}

  defp consume_components(tokens, components) do
    with {:ok, component, rest} <- build_component_value(tokens) do
      consume_components(rest, [component | components])
    end
  end

  # A component value without positions, as structs hold their values; structs keep their own.
  defp plain({type, value, _position}), do: {type, value}
  defp plain(%SimpleBlock{value: value} = block), do: %{block | value: Enum.map(value, &plain/1)}

  defp plain(%Function{value: value} = function),
    do: %{function | value: Enum.map(value, &plain/1)}

  defp drop_semicolon(components) do
    case Enum.reverse(components) do
      [{:semicolon, _, _} | rest] -> Enum.reverse(rest)
      _ -> components
    end
  end

  defp skip_whitespace([{:whitespace, _, _} | rest]), do: skip_whitespace(rest)
  defp skip_whitespace(components), do: components

  defp trim_whitespace(components),
    do: components |> skip_whitespace() |> Enum.reverse() |> skip_whitespace() |> Enum.reverse()

  defp position({_type, _value, position}), do: position
  defp position(%{line: line, column: column}), do: {line, column}

  defp error(message, nil), do: {:error, %ParseError{message: message}}

  defp error(message, at) do
    {line, column} = position(at)
    {:error, %ParseError{message: message, line: line, column: column}}
  end
end
