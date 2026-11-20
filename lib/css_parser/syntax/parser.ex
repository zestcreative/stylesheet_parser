defmodule CssParser.Syntax.Parser do
  @moduledoc """
  The parsing algorithms of [CSS Syntax Level 3](https://www.w3.org/TR/css-syntax-3/#parsing), as
  its current draft has them with [CSS Nesting](https://www.w3.org/TR/css-nesting-1/), over the
  tokenizer's tokens, `{type, value, metadata}` with `[line: l, column: c]`, like Elixir AST.

  Rules, declarations, functions and simple blocks carry the `line` and `column` where they start.
  The component values inside them (a declaration's value, an at-rule's prelude, a block's or a
  function's value) are `{type, value}`, without positions.

  A qualified rule's prelude is its selector list (`CssParser.Selector.Parser`), with relative
  selectors such as `> a` when it's nested in a style rule, or in `@keyframes` its component
  values, such as `50%`. A block, a style rule's or an at-rule's, is its declarations and rules in
  order.

  Malformed input is dropped, as the spec recovers from it: a declaration with no colon, anything
  else where a declaration belongs, a rule whose selectors don't parse or that ends before its
  block. An unclosed block or function closes at the end of the input. `parse_stylesheet/1` keeps
  each as a `CssParser.Syntax.Parser.ParseError` in the stylesheet's `errors`, with the line and
  column where it is; `parse_rules/2` and `parse_declarations/1` return them with their results.
  """

  alias CssParser.Selector.Parser, as: Selector

  alias CssParser.{
    AtRule,
    Declaration,
    QualifiedRule,
    Function,
    Serialize,
    SimpleBlock,
    Stylesheet
  }

  defmodule ParseError do
    defexception [:message, :line, :column]

    @impl true
    def message(%{message: message, line: nil}), do: message

    def message(%{message: message, line: line, column: column}),
      do: "#{line}:#{column}: #{message}"
  end

  @doc """
  # 5.3.2. Parse a stylesheet

  1. Create a new stylesheet.
  2. Consume a list of rules from the stream of tokens, with the top-level flag set. Let the return value be rules.
  3. Assign rules to the stylesheet’s value.
  4. Return the stylesheet.
  """
  def parse_stylesheet(tokens) do
    {components, errors} = consume_components(tokens, [], [])
    {rules, errors} = consume_rules(components, context(top_level: true), [], errors)
    {:ok, %Stylesheet{rules: rules, errors: Enum.reverse(errors)}}
  end

  @doc """
  # 5.3.3. Parse a list of rules

  1. Consume a list of rules from the stream of tokens, with the top-level flag unset.
  2. Return the returned list.

  Returns `{:ok, rules, errors}`, the errors as a stylesheet's are.
  """
  def parse_rules(tokens, opts \\ []) do
    {components, errors} = consume_components(tokens, [], [])
    {rules, errors} = consume_rules(components, context(opts), [], errors)
    {:ok, rules, Enum.reverse(errors)}
  end

  # Where rules are: at the top level, nested in a style rule, or in `@keyframes`.
  defp context(opts),
    do: %{top_level: opts[:top_level] || false, nested: false, keyframes: false}

  # 5.4.1. Consume a list of rules
  defp consume_rules([], _context, rules, errors), do: {Enum.reverse(rules), errors}

  defp consume_rules([{:whitespace, _, _} | rest], context, rules, errors),
    do: consume_rules(rest, context, rules, errors)

  defp consume_rules([{cdo_or_cdc, _, _} | rest], %{top_level: true} = context, rules, errors)
       when cdo_or_cdc in [:cdo, :cdc],
       do: consume_rules(rest, context, rules, errors)

  defp consume_rules([first | _] = components, context, rules, errors) do
    case consume_rule(components, context, errors) do
      {:no_block, rest, errors} ->
        error = parse_error("expected { after the selector", first)
        consume_rules(rest, context, rules, [error | errors])

      {rule, rest, errors} ->
        consume_rules(rest, context, prepend(rule, rules), errors)
    end
  end

  defp consume_rule([{:at_keyword, _, _} | _] = components, context, errors),
    do: consume_at_rule(components, context, errors)

  defp consume_rule(components, context, errors),
    do: consume_qualified_rule(components, context, nil, errors)

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
    {components, _errors} = consume_components(tokens, [], [])

    case skip_whitespace(components) do
      [] -> error("expected a rule", nil)
      [first | _] = components -> one_rule(first, components, context(opts))
    end
  end

  defp one_rule(first, components, context) do
    case consume_rule(components, context, []) do
      {:no_block, _rest, _errors} -> error("expected { after the selector", first)
      {nil, _rest, [error | _]} -> {:error, error}
      {rule, rest, _errors} -> only(rule, rest, "expected one rule")
    end
  end

  @doc """
  # 5.3.5. Parse a declaration

  1. While the next input token is a `<whitespace-token>`, consume the next input token.
  2. If the next input token is not an `<ident-token>`, return a syntax error.
  3. Consume a declaration. If anything was returned, return it. Otherwise, return a syntax error.
  """
  def parse_declaration(tokens) do
    {components, _errors} = consume_components(tokens, [], [])

    case skip_whitespace(components) do
      [{:ident, _, _} | _] = components ->
        # A declaration written on its own may end with its `;`.
        components |> trim_whitespace() |> drop_semicolon() |> build_declaration()

      [other | _] ->
        error("expected a declaration", other)

      [] ->
        error("expected a declaration", nil)
    end
  end

  @doc """
  # 5.3.6. Parse a list of declarations

  The draft's "parse a block's contents": the declarations, at-rules and nested style rules of a
  style attribute, in order. Returns `{:ok, contents, errors}`, the errors as a stylesheet's are.
  """
  def parse_declarations(tokens) do
    {components, errors} = consume_components(tokens, [], [])
    context = %{top_level: false, nested: true, keyframes: false}
    {contents, errors} = consume_block_contents(components, context, [], errors)
    {:ok, contents, Enum.reverse(errors)}
  end

  @doc """
  # 5.3.7. Parse a component value

  1. While the next input token is a `<whitespace-token>`, consume the next input token.
  2. If the next input token is an `<EOF-token>`, return a syntax error.
  3. Consume a component value and let value be the return value.
  4. While the next input token is a `<whitespace-token>`, consume the next input token.
  5. If the next input token is an `<EOF-token>`, return value. Otherwise, return a syntax error.
  """
  def parse_component_value(tokens) do
    {components, _errors} = consume_components(tokens, [], [])

    case skip_whitespace(components) do
      [] -> error("expected a component value", nil)
      [value | rest] -> only(plain(value), rest, "expected one component value")
    end
  end

  @doc """
  # 5.3.8. Parse a list of component values

  1. Repeatedly consume a component value until an `<EOF-token>` is returned, appending the
     returned values (except the final `<EOF-token>`) into a list. Return the list.
  """
  def parse_component_values(tokens) do
    {components, _errors} = consume_components(tokens, [], [])
    {:ok, Enum.map(components, &plain/1)}
  end

  defp only(value, rest, message) do
    case skip_whitespace(rest) do
      [] -> {:ok, value}
      [extra | _] -> error(message, extra)
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

  The block is its declarations and rules (the draft's "consume a block's contents"). Returns the
  component values after the at-rule.
  """
  def build_at_rule(tokens, opts \\ []) do
    {components, _errors} = consume_components(tokens, [], [])
    {at_rule, rest, _errors} = consume_at_rule(components, context(opts), [])
    {:ok, at_rule, rest}
  end

  defp consume_at_rule([{:at_keyword, name, _} = token | rest], context, errors) do
    {line, column} = position(token)
    at_rule = %AtRule{name: name, line: line, column: column, top_level: context.top_level}
    consume_at_rule(rest, at_rule, [], context, errors)
  end

  defp consume_at_rule([], at_rule, prelude, _context, errors),
    do: {finish_at_rule(at_rule, prelude), [], errors}

  defp consume_at_rule([{:semicolon, _, _} | rest], at_rule, prelude, _context, errors),
    do: {finish_at_rule(at_rule, prelude), rest, errors}

  defp consume_at_rule(
         [%SimpleBlock{terminator: :rcurly, value: value} | rest],
         at_rule,
         prelude,
         context,
         errors
       ) do
    keyframes = at_rule.name |> String.downcase() |> String.ends_with?("keyframes")
    context = %{context | top_level: false, keyframes: keyframes}
    {contents, errors} = consume_block_contents(value, context, [], errors)
    {%{finish_at_rule(at_rule, prelude) | block: contents}, rest, errors}
  end

  defp consume_at_rule([component | rest], at_rule, prelude, context, errors),
    do: consume_at_rule(rest, at_rule, [component | prelude], context, errors)

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

  A rule whose prelude isn't a selector list is nothing too, a syntax error. Returns the component
  values after the rule.
  """
  def build_qualified_rule([first | _] = tokens, opts \\ []) do
    {components, _errors} = consume_components(tokens, [], [])

    case consume_qualified_rule(components, context(opts), nil, []) do
      {:no_block, _rest, _errors} -> error("expected { after the selector", first)
      {nil, _rest, [error | _]} -> {:error, error}
      {rule, rest, _errors} -> {:ok, rule, rest}
    end
  end

  # `:no_block` when the input, or with `:semicolon` as the stop token a `;`, comes first.
  defp consume_qualified_rule([first | _] = components, context, stop, errors) do
    {line, column} = position(first)
    rule = %QualifiedRule{line: line, column: column, top_level: context.top_level}
    consume_qualified_rule(components, rule, [], context, stop, errors)
  end

  defp consume_qualified_rule([], _rule, _prelude, _context, _stop, errors),
    do: {:no_block, [], errors}

  defp consume_qualified_rule([{:semicolon, _, _} | _] = rest, _rule, _, _, :semicolon, errors),
    do: {:no_block, rest, errors}

  defp consume_qualified_rule(
         [%SimpleBlock{terminator: :rcurly, value: value} | rest],
         rule,
         prelude,
         context,
         _stop,
         errors
       ) do
    prelude = prelude |> Enum.reverse() |> trim_whitespace() |> Enum.map(&plain/1)

    case selectors(prelude, context) do
      {:ok, selectors} ->
        context = %{context | top_level: false, nested: not context.keyframes, keyframes: false}
        {block, errors} = consume_block_contents(value, context, [], errors)
        {%{rule | prelude: selectors, block: block}, rest, errors}

      :error ->
        {nil, rest, [parse_error("invalid selector", rule) | errors]}
    end
  end

  defp consume_qualified_rule([component | rest], rule, prelude, context, stop, errors),
    do: consume_qualified_rule(rest, rule, [component | prelude], context, stop, errors)

  defp selectors(prelude, %{keyframes: true}), do: {:ok, prelude}

  defp selectors(prelude, %{nested: nested}) do
    parsed =
      if nested,
        do: Selector.relative_selector_list(prelude),
        else: Selector.selector_list(prelude)

    case parsed do
      {[_ | _] = selectors, []} -> {:ok, selectors}
      _ -> :error
    end
  end

  # The draft's 5.4.4. Consume a block's contents: its declarations and rules, in order. Where a
  # declaration doesn't parse, a nested rule may; if neither, the declaration's error is kept and
  # parsing goes on after the next `;`.
  defp consume_block_contents([], _context, items, errors), do: {Enum.reverse(items), errors}

  defp consume_block_contents([{skip, _, _} | rest], context, items, errors)
       when skip in [:whitespace, :semicolon],
       do: consume_block_contents(rest, context, items, errors)

  defp consume_block_contents([{:at_keyword, _, _} | _] = components, context, items, errors) do
    {at_rule, rest, errors} = consume_at_rule(components, context, errors)
    consume_block_contents(rest, context, [at_rule | items], errors)
  end

  defp consume_block_contents(components, context, items, errors) do
    {declaration, rest} = Enum.split_while(components, &(not match?({:semicolon, _, _}, &1)))

    {item, rest, errors} =
      case build_declaration(declaration) do
        {:ok, declaration} -> {declaration, rest, errors}
        {:error, error} -> nested_rule(components, context, error, errors)
      end

    consume_block_contents(rest, context, prepend(item, items), errors)
  end

  defp nested_rule(components, context, declaration_error, errors) do
    case consume_qualified_rule(components, context, :semicolon, errors) do
      {:no_block, rest, errors} -> {nil, rest, [declaration_error | errors]}
      result -> result
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
  """
  def build_simple_block(tokens) do
    {block, rest, _errors} = simple_block(tokens, [])
    {:ok, block, rest}
  end

  defp simple_block([{opening, _, _} = token | tokens], errors)
       when opening in [:lcurly, :lbracket, :lparen] do
    {line, column} = position(token)
    terminator = %{lcurly: :rcurly, lbracket: :rbracket, lparen: :rparen}[opening]
    block = %SimpleBlock{terminator: terminator, line: line, column: column}
    consume_simple_block(tokens, block, [], errors)
  end

  defp consume_simple_block([], block, value, errors) do
    error = parse_error("unclosed #{opening(block.terminator)}", block)
    {%{block | value: Enum.reverse(value)}, [], [error | errors]}
  end

  defp consume_simple_block(
         [{terminator, _, _} | rest],
         %{terminator: terminator} = block,
         value,
         errors
       ),
       do: {%{block | value: Enum.reverse(value)}, rest, errors}

  defp consume_simple_block(tokens, block, value, errors) do
    {component, rest, errors} = component(tokens, errors)
    consume_simple_block(rest, block, [component | value], errors)
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
  """
  def build_function(tokens) do
    {function, rest, _errors} = function(tokens, [])
    {:ok, function, rest}
  end

  defp function([{:function, name, _} = token | tokens], errors) do
    {line, column} = position(token)
    function = %Function{name: String.trim_trailing(name, "("), line: line, column: column}
    consume_function(tokens, function, [], errors)
  end

  defp consume_function([], function, value, errors) do
    error = parse_error("unclosed #{function.name}(", function)
    {%{function | value: Enum.reverse(value)}, [], [error | errors]}
  end

  defp consume_function([{:rparen, _, _} | rest], function, value, errors),
    do: {%{function | value: Enum.reverse(value)}, rest, errors}

  defp consume_function(tokens, function, value, errors) do
    {component, rest, errors} = component(tokens, errors)
    consume_function(rest, function, [component | value], errors)
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

  From the draft: unless it's a custom property, a value with a `{}` block in it is the block
  alone, else it's nothing; and a `unicode-range` value has its `:urange`s, such as `U+0-7F`.
  """
  def build_declaration([{:ident, name, _} = ident | components]) do
    {line, column} = position(ident)

    with [{:colon, _, _} | value] <- skip_whitespace(components),
         {value, important} = value |> trim_whitespace() |> important(),
         value = Enum.map(value, &plain/1),
         true <- custom_property?(name) or not block_among_others?(value) do
      {:ok,
       %Declaration{
         name: name,
         value:
           if(String.downcase(name) == "unicode-range", do: unicode_ranges(value), else: value),
         important: important,
         line: line,
         column: column
       }}
    else
      false -> error("expected a declaration", ident)
      _ -> error("expected : after #{name}", ident)
    end
  end

  def build_declaration([other | _]), do: error("expected a declaration", other)

  defp custom_property?(name), do: String.starts_with?(name, "--")

  defp block_among_others?(value) do
    Enum.any?(value, &match?(%SimpleBlock{terminator: :rcurly}, &1)) and
      Enum.count(value, &(not match?({:whitespace, _}, &1))) > 1
  end

  # A unicode range such as `U+0-7F` tokenizes as an ident, a number and a dimension, so each run
  # between whitespace and commas that reads as one is an `:urange`.
  defp unicode_ranges(value) do
    value
    |> Enum.chunk_by(&match?({type, _} when type in [:whitespace, :comma], &1))
    |> Enum.flat_map(fn run ->
      text = Enum.map_join(run, &Serialize.value/1)

      if Regex.match?(
           ~r/\A[uU]\+(?:[0-9a-fA-F]{1,6}-[0-9a-fA-F]{1,6}|[0-9a-fA-F]{1,6}|(?=[0-9a-fA-F?]{1,6}\z)[0-9a-fA-F]*\?+)\z/,
           text
         ),
         do: [{:urange, text}],
         else: run
    end)
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
  def build_component_value(tokens) do
    {component, rest, _errors} = component(tokens, [])
    {:ok, component, rest}
  end

  defp component([{opening, _, _} | _] = tokens, errors)
       when opening in [:lcurly, :lbracket, :lparen],
       do: simple_block(tokens, errors)

  defp component([{:function, _, _} | _] = tokens, errors), do: function(tokens, errors)
  defp component([token | rest], errors), do: {token, rest, errors}

  defp consume_components([], components, errors), do: {Enum.reverse(components), errors}

  defp consume_components(tokens, components, errors) do
    {component, rest, errors} = component(tokens, errors)
    consume_components(rest, [component | components], errors)
  end

  # A component value without positions, as structs hold their values; structs keep their own.
  defp plain({type, value, _metadata}), do: {type, value}
  defp plain(%SimpleBlock{value: value} = block), do: %{block | value: Enum.map(value, &plain/1)}

  defp plain(%Function{value: value} = function),
    do: %{function | value: Enum.map(value, &plain/1)}

  defp prepend(nil, list), do: list
  defp prepend(item, list), do: [item | list]

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

  defp position({_type, _value, metadata}), do: {metadata[:line], metadata[:column]}
  defp position(%{line: line, column: column}), do: {line, column}

  defp error(message, at), do: {:error, parse_error(message, at)}

  defp parse_error(message, nil), do: %ParseError{message: message}

  defp parse_error(message, at) do
    {line, column} = position(at)
    %ParseError{message: message, line: line, column: column}
  end
end
