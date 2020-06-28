defmodule CssParser.Parser do
  defmodule ParseError do
    defexception [:message, :remaining_tokens]
  end

  defmodule Stylesheet do
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

  defmodule AtRule do
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

  defmodule QualifiedRule do
    defstruct [:block, :block_token, value: [], prelude: [], top_level: false]

    defimpl String.Chars, for: __MODULE__ do
      defp token_to_string({:delim, "\\"}), do: "\\\n"
      defp token_to_string({_token, value}), do: Kernel.to_string(value)
      defp token_to_string(value), do: Kernel.to_string(value)

      def to_string(%{block: nil} = qualified_rule) do
        "#{Enum.map(qualified_rule.prelude, &token_to_string/1)};"
      end
      def to_string(qualified_rule) do
        "#{Enum.map(qualified_rule.prelude, &token_to_string/1)}#{token_to_string(qualified_rule.block_token)}#{token_to_string(qualified_rule.block)}\n"
      end
    end
  end

  defmodule Declaration do
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

  defmodule Function do
    defstruct [:name, value: []]

    defimpl String.Chars, for: __MODULE__ do
      defp token_to_string({:delim, "\\"}), do: "\\\n"
      defp token_to_string({_token, value}), do: Kernel.to_string(value)
      defp token_to_string(value), do: Kernel.to_string(value)

      def to_string(function) do
        "#{function.name}(#{Enum.map(function.value, &token_to_string/1)})"
      end
    end
  end

  defmodule SimpleBlock do
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

  @doc """
  # 5.3.2. Parse a stylesheet

  To parse a stylesheet from a stream of tokens:

  1. Create a new stylesheet.
  2. Consume a list of rules from the stream of tokens, with the top-level flag set. Let the return
      value be rules.
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

  To parse a list of rules from a stream of tokens:

  1. Consume a list of rules from the stream of tokens, with the top-level flag unset.
  2. Return the returned list.
  """
  def parse_rules(tokens), do: parse_rules(tokens, top_level: false)
  def parse_rules(tokens, top_level: top_level) do
    do_parse_rules(tokens, [], top_level)
  end

  defp do_parse_rules([], rules, _top_level), do: {:ok, Enum.reverse(rules)}
  defp do_parse_rules([{:whitespace, _} | rest], rules, top_level) do
    do_parse_rules(rest, rules, top_level)
  end
  defp do_parse_rules([{:cdo, _} | rest], rules, true) do
    do_parse_rules(rest, rules, true)
  end
  defp do_parse_rules([{:cdo, _} | _rest] = tokens, rules, false) do
    with {:ok, qualified_rule, rest} <- build_qualified_rule(tokens, top_level: false) do
      do_parse_rules(rest, [qualified_rule | rules], false)
    end
  end
  defp do_parse_rules([{:cdc, _} | rest], rules, true) do
    do_parse_rules(rest, rules, true)
  end
  defp do_parse_rules([{:cdc, _} | _rest] = tokens, rules, false) do
    with {:ok, qualified_rule, rest} <- build_qualified_rule(tokens, top_level: false) do
      do_parse_rules(rest, [qualified_rule | rules], false)
    end
  end
  defp do_parse_rules([{:at_keyword, _} | _] = tokens, rules, top_level) do
    with {:ok, at_rule, rest} <- build_at_rule(tokens, top_level: top_level) do
      do_parse_rules(rest, [at_rule | rules], top_level)
    end
  end
  defp do_parse_rules(tokens, rules, top_level) do
    with {:ok, qualified_rule, rest} <- build_qualified_rule(tokens, top_level: top_level) do
      do_parse_rules(rest, [qualified_rule | rules], top_level)
    end
  end


  @doc """
  # 5.3.4. Parse a rule

  To parse a rule from a stream of tokens:

  1. While the next input token is a `<whitespace-token>`, consume the next input token.
  2. If the next input token is an `<EOF-token>`, return a syntax error.
     Otherwise, if the next input token is an `<at-keyword-token>`, consume an at-rule, and let rule
     be the return value.
     Otherwise, consume a qualified rule and let rule be the return value. If nothing was returned,
     return a syntax error.
  3. While the next input token is a `<whitespace-token>`, consume the next input token.
  4. If the next input token is an `<EOF-token>`, return rule. Otherwise, return a syntax error.
  """
  def parse_rule(tokens), do: parse_rule(tokens, top_level: false)
  def parse_rule(tokens, top_level: top_level) do
    do_parse_rule(tokens, top_level)
  end

  defp do_parse_rule([], _top_level), do: {:error, %ParseError{message: "syntax error"}}
  defp do_parse_rule([{:whitespace, _} | rest], top_level) do
    do_parse_rule(rest, top_level)
  end

  defp do_parse_rule([{:at_keyword, _} | _rest] = tokens, top_level) do
    with {:ok, at_rule, _rest} <- build_at_rule(tokens, top_level: top_level) do
      {:ok, at_rule}
    end
  end

  defp do_parse_rule(tokens, top_level) do
    with {:ok, qualified_rule, _rest} <- build_qualified_rule(tokens, top_level: top_level) do
      {:ok, qualified_rule}
    end
  end

  @doc """
  # 5.3.5. Parse a declaration

  **Note**: Unlike "Parse a list of declarations", this parses only a declaration and not an at-rule.

  To parse a declaration:

  1. While the next input token is a `<whitespace-token>`, consume the next input token.
  2. If the next input token is not an `<ident-token>`, return a syntax error.
  3. Consume a declaration. If anything was returned, return it. Otherwise, return a syntax error.
  """
  def parse_declaration([{:whitespace, _} | tokens]), do: parse_declaration(tokens)
  def parse_declaration([{:ident, _} | _rest] = tokens) do
    with {:ok, declaration, _rest} <- build_declaration(tokens) do
      {:ok, declaration}
    end
  end
  def parse_declaration(_tokens), do: {:error, %ParseError{message: "invalid declaration"}}

  @doc """
  # 5.3.6. Parse a list of declarations

  **Note** Despite the name, this actually parses a mixed list of declarations and at-rules, as CSS
  2.1 does for @page. Unexpected at-rules (which could be all of them, in a given context) are
  invalid and should be ignored by the consumer.

  To parse a list of declarations:

  1. Consume a list of declarations.
  2. Return the returned list.

  # 5.4.4. Consume a list of declarations

  To consume a list of declarations:

  Create an initially empty list of declarations.

  Repeatedly consume the next input token:

  - `<whitespace-token>` or `<semicolon-token>` Do nothing.
  - `<EOF-token>` Return the list of declarations.
  - `<at-keyword-token>` Reconsume the current input token. Consume an at-rule. Append the returned
      rule to the list of declarations.
  - `<ident-token>` Initialize a temporary list initially filled with the current input token. As
    long as the next input token is anything other than a <semicolon-token> or <EOF-token>, consume
    a component value and append it to the temporary list. Consume a declaration from the temporary
    list. If anything was returned, append it to the list of declarations.
  - anything else: This is a parse error. Reconsume the current input token. As long as the next
    input token is anything other than a <semicolon-token> or <EOF-token>, consume a component value
    and throw away the returned value.
  """
  def parse_declarations(tokens), do: do_parse_declarations(tokens, [])

  defp do_parse_declarations([], declarations), do: {:ok, Enum.reverse(declarations)}

  defp do_parse_declarations([{:whitespace, _} | rest], declarations) do
    do_parse_declarations(rest, declarations)
  end

  defp do_parse_declarations([{:semicolon, _} | rest], declarations) do
    do_parse_declarations(rest, declarations)
  end

  defp do_parse_declarations([{:at_keyword, _} | _rest] = tokens, declarations) do
    with {:ok, at_rule, tokens} <- build_at_rule(tokens) do
      do_parse_declarations(tokens, [at_rule | declarations])
    end
  end

  defp do_parse_declarations([{:ident, _} | _rest] = tokens, declarations) do
    with {:ok, declaration, tokens} <- build_declaration(tokens) do
      do_parse_declarations(tokens, [declaration | declarations])
    end
  end

  defp do_parse_declarations(tokens, _declarations), do: %ParseError{message: "declarations error", remaining_tokens: tokens}

  @doc """
  # 5.3.7. Parse a component value

  To parse a component value:

  1. While the next input token is a `<whitespace-token>`, consume the next input token.
  2. If the next input token is an `<EOF-token>`, return a syntax error.
  3. Consume a component value and let value be the return value.
  4. While the next input token is a `<whitespace-token>`, consume the next input token.
  5. If the next input token is an `<EOF-token>`, return value. Otherwise, return a syntax error.
  """

  def parse_component_value([{:whitespace, _} | tokens]), do: parse_component_value(tokens)
  def parse_component_value([]), do: {:error, %ParseError{message: "invalid component value"}}
  def parse_component_value(tokens), do: do_parse_component_value(tokens, nil)

  defp do_parse_component_value([], nil), do: {:error, %ParseError{message: "invalid component value"}}
  defp do_parse_component_value([{:whitespace, _} | rest], value) do
    do_parse_component_value(rest, value)
  end
  defp do_parse_component_value([{_, value} | rest], nil) do
    do_parse_component_value(rest, value)
  end
  defp do_parse_component_value(rest, value), do: {:ok, value, rest}

  @doc """
  # 5.3.8. Parse a list of component values

  To parse a list of component values:

  1. Repeatedly consume a component value until an `<EOF-token>` is returned, appending the returned
    values (except the final `<EOF-token>`) into a list. Return the list.
  """
  def parse_component_values(tokens), do: do_parse_component_values(tokens, [])

  defp do_parse_component_values([], values) do
    {:ok, Enum.reverse(values)}
  end
  defp do_parse_component_values(tokens, values) do
    with {:ok, value, rest} <- parse_component_value(tokens) do
      do_parse_component_value(rest, [value | values])
    end
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
  def build_at_rule([{:at_keyword, name} | tokens], opts \\ []) do
    at_rule = %AtRule{name: name, top_level: opts[:top_level] || false}
    with {:ok, at_rule, rest} <- do_build_at_rule(tokens, at_rule) do
      {:ok, at_rule, rest}
    end
  end
  def do_build_at_rule([], at_rule), do: {:error, %ParseError{message: "invalid component value", remaining_tokens: [at_rule]}}
  def do_build_at_rule([{:semicolon, _} | rest], at_rule) do
    {:ok, %{at_rule | prelude: Enum.reverse(at_rule.prelude)}, rest}
  end
  def do_build_at_rule([{:lcurly, _} | _] = tokens, at_rule) do
    with {:ok, simple_block, rest} <- build_simple_block(tokens) do
      {:ok, %{at_rule | prelude: Enum.reverse(at_rule.prelude), block: simple_block}, rest}
    end
  end
  def do_build_at_rule(tokens, at_rule) do
    with {:ok, value, rest} <- build_component_value(tokens) do
      do_build_at_rule(rest, %{at_rule | prelude: [value | at_rule.prelude]})
    end
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
  def build_qualified_rule(tokens, opts \\ [])
  def build_qualified_rule(tokens, opts) do
    qualified_rule = %QualifiedRule{top_level: opts[:top_level] || false}
    with {:ok, qualified_rule, rest} <- do_build_qualified_rule(tokens, qualified_rule) do
      {:ok, %{qualified_rule |
        value: Enum.reverse(qualified_rule.value),
        prelude: Enum.reverse(qualified_rule.prelude)
      }, rest}
    end
  end
  def do_build_qualified_rule([], _qualified_rule), do: {:error, %ParseError{message: "invalid qualified rule"}}

  def do_build_qualified_rule([{:lcurly, _} | _] = tokens, qualified_rule) do
    with {:ok, simple_block, rest} <- build_simple_block(tokens) do
      {:ok, %{qualified_rule | block: simple_block}, rest}
    end
  end

  def do_build_qualified_rule(tokens, qualified_rule) do
    with {:ok, component_value, rest} <- build_component_value(tokens) do
      do_build_qualified_rule(rest, %{qualified_rule | prelude: [component_value | qualified_rule.prelude]})
    end
  end

  @doc """
  # 5.4.7. Consume a simple block

  Note: This algorithm assumes that the current input token has already been checked to be an
  `<{-token>`, `<[-token>`, or `<(-token>`.

  To consume a simple block:

  The ending token is the mirror variant of the current input token. (E.g. if it was called with
  `<[-token>`, the ending token is `<]-token>`.)

  Create a simple block with its associated token set to the current input token and with a value
  with is initially an empty list.

  Repeatedly consume the next input token and process it as follows:

  - ending token: Return the block.
  - `<EOF-token>`: This is a parse error. Return the block.
  - anything else: Reconsume the current input token. Consume a component value and append it to the
    value of the block.

  **Note**: CSS has an unfortunate syntactic ambiguity between blocks that can contain declarations
  and blocks that can contain qualified rules, so any "consume" algorithms that handle rules will
  initially use this more generic algorithm rather than the more specific consume a list of
  declarations or consume a list of rules algorithms. These more specific algorithms are instead
  invoked when grammars are applied, depending on whether it contains a <declaration-list> or a
  <rule-list>/<stylesheet>.
  """
  def build_simple_block([{:lcurly, _} | tokens]) do
    do_build_simple_block(tokens, %SimpleBlock{terminator: :rcurly})
  end
  def build_simple_block([{:lbracket, _} | tokens]) do
    do_build_simple_block(tokens, %SimpleBlock{terminator: :rbracket})
  end
  def build_simple_block([{:lparen, _} | tokens]) do
    do_build_simple_block(tokens, %SimpleBlock{terminator: :rparen})
  end

  defp do_build_simple_block([], simple_block), do: {:error, %ParseError{message: "invalid simple block", remaining_tokens: [simple_block]}}
  defp do_build_simple_block([{terminator, _} | rest], %{terminator: terminator} = simple_block) do
    {:ok, %{simple_block | value: Enum.reverse(simple_block.value)}, rest}
  end
  defp do_build_simple_block(tokens, simple_block) do
    with {:ok, component_value, rest} = build_component_value(tokens) do
      do_build_simple_block(rest, %{simple_block | value: [component_value | simple_block.value]})
    end
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
  def build_function([{:function, name} | tokens]) do
    name = String.replace_suffix(name, "(", "")
    function = %Function{name: name}
    do_build_function(tokens, function)
  end
  def do_build_function([], function), do: {:error, %ParseError{message: "invalid function", remaining_tokens: [function]}}
  def do_build_function([{:rparen, _} | rest], function) do
    {:ok, %{function | value: Enum.reverse(function.value)}, rest}
  end
  def do_build_function(tokens, function) do
    with {:ok, component_value, rest} <- build_component_value(tokens) do
      do_build_function(rest, %{function | value: [component_value | function.value]})
    end
  end

  @doc """
  # 5.4.5. Consume a declaration

  **Note**: This algorithm assumes that the next input token has already been checked to be an
  <ident-token>.

  To consume a declaration:

  Consume the next input token. Create a new declaration with its name set to the value of the
  current input token and its value initially set to the empty list.

  1. While the next input token is a <whitespace-token>, consume the next input token.
  2. If the next input token is anything other than a <colon-token>, this is a parse error. Return
      nothing. Otherwise, consume the next input token.
  3. While the next input token is a <whitespace-token>, consume the next input token.
  4. As long as the next input token is anything other than an <EOF-token>, consume a component
      value and append it to the declaration’s value.
  5. If the last two non-<whitespace-token>s in the declaration’s value are a <delim-token> with the
      value "!" followed by an <ident-token> with a value that is an ASCII case-insensitive match
      for "important", remove them from the declaration’s value and set the declaration’s important
      flag to true.
  6. While the last token in the declaration’s value is a <whitespace-token>, remove that token.
  7. Return the declaration.
  """

  def build_declaration([{:whitespace, _}, {:ident, name} | tokens]) do
    declaration = %Declaration{name: name}
    do_build_declaration(tokens, declaration)
  end
  def build_declaration([{:ident, name} | tokens]) do
    declaration = %Declaration{name: name}
    do_build_declaration(tokens, declaration)
  end
  def build_declaration(tokens), do: {:error, %ParseError{message: "invalid declaration", remaining_tokens: [tokens]}}

  defp do_build_declaration([], %{value: []}), do: {:error, %ParseError{message: "invalid declaration"}}
  defp do_build_declaration([], declaration), do: finish_declaration(declaration, [])
  defp do_build_declaration([{:whitespace, _} | rest], declaration) do
    do_build_declaration(rest, declaration)
  end
  defp do_build_declaration([{:colon, _} | rest], declaration) do
    do_build_declaration(rest, declaration)
  end
  defp do_build_declaration([{:semicolon, _} | rest], declaration) do
    finish_declaration(declaration, rest)
  end
  defp do_build_declaration(tokens, declaration) do
    with {:ok, component_value, rest} <- build_component_value(tokens) do
      do_build_declaration(rest, %{declaration | value: [component_value | declaration.value]})
    end
  end

  defp finish_declaration(%{value: [{:ident, important}, {:delim, "!"} | value]} = declaration, rest) do
    if String.downcase(important) == "important" do
      {:ok, %{declaration | value: Enum.reverse(value), important: true}, rest}
    else
      {:ok, %{declaration | value: Enum.reverse(value)}, rest}
    end
  end
  defp finish_declaration(declaration, rest) do
    {:ok, %{declaration | value: Enum.reverse(declaration.value)}, rest}
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
end
