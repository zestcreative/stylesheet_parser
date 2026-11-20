defmodule StylesheetParser.Selector.Parser do
  @moduledoc """
  [Selectors Level 4](https://www.w3.org/TR/selectors-4/), over component values, as
  `StylesheetParser.parse_component_values/1` returns them: an attribute selector is a `[]`
  `StylesheetParser.SimpleBlock`, and a functional pseudo-class or pseudo-element is a
  `StylesheetParser.Function`, its arguments its component values, except for the pseudo-classes whose
  arguments parse here, a `StylesheetParser.PseudoClass`: `:is()`, `:where()`, `:not()` and the
  `:nth-*()` ones. `&` is the nesting selector of
  [CSS Nesting](https://www.w3.org/TR/css-nesting-1/).

  Each parser returns what it parsed, or nil, and the component values after it. A selector list
  parses whole when nothing is after it:

      iex> {:ok, values} = StylesheetParser.parse_component_values("nav > a:hover, .button")
      iex> {selectors, []} = StylesheetParser.Selector.Parser.selector_list(values)
      iex> Enum.map(selectors, &to_string/1)
      ["nav > a:hover", ".button"]

      iex> {:ok, values} = StylesheetParser.parse_component_values("a, #1st")
      iex> {[%StylesheetParser.SimpleSelector{value: "a"}], rest} =
      ...>   StylesheetParser.Selector.Parser.selector_list(values)
      iex> rest
      [comma: ",", whitespace: " ", hash: "#1st"]

  A nested rule's selectors may be relative, as `> a`:

      iex> {:ok, values} = StylesheetParser.parse_component_values("> a, + b")
      iex> {selectors, []} = StylesheetParser.Selector.Parser.relative_selector_list(values)
      iex> Enum.map(selectors, &to_string/1)
      ["> a", "+ b"]
  """

  alias StylesheetParser.{Function, PseudoClass, SimpleBlock, SimpleSelector}
  alias StylesheetParser.{CompoundSelector, ComplexSelector}

  @doc """
      <selector-list> = <complex-selector-list>
      <complex-selector-list> = <complex-selector>#
  """
  def selector_list(tokens), do: comma_list(tokens, &complex_selector/1)

  @doc """
      <compound-selector-list> = <compound-selector>#
  """
  def compound_selector_list(tokens), do: comma_list(tokens, &compound_selector/1)

  @doc """
      <simple-selector-list> = <simple-selector>#
  """
  def simple_selector_list(tokens), do: comma_list(tokens, &simple_selector/1)

  @doc """
      <relative-selector-list> = <relative-selector>#
  """
  def relative_selector_list(tokens), do: comma_list(tokens, &relative_selector/1)

  # Selectors with a comma and any whitespace between them. A trailing comma is left over, so
  # `a,` isn't a whole list.
  defp comma_list(tokens, parse) do
    case parse.(ignore_whitespace(tokens)) do
      {nil, _rest} ->
        {[], tokens}

      {selector, rest} ->
        {selectors, rest} = after_comma(ignore_whitespace(rest), rest, parse)
        {[selector | selectors], rest}
    end
  end

  defp after_comma([{:comma, _} | more], rest, parse) do
    case comma_list(more, parse) do
      {[], _more} -> {[], rest}
      selectors -> selectors
    end
  end

  defp after_comma(_tokens, rest, _parse), do: {[], rest}

  @doc false
  def ignore_whitespace([{:whitespace, _} | rest]), do: ignore_whitespace(rest)
  def ignore_whitespace(tokens), do: tokens

  # <class-selector> = '.' <ident-token>
  def class_selector([{:delim, "."}, {:ident, ident} | tokens]),
    do: {{:class, ".#{ident}"}, tokens}

  def class_selector(tokens), do: {nil, tokens}

  # <id-selector> = <hash-token>, of the "id" type: its name would start an ident.
  def id_selector([{:hash, "#" <> name = id} | tokens] = all) do
    if ident_start?(name), do: {{:id, id}, tokens}, else: {nil, all}
  end

  def id_selector(tokens), do: {nil, tokens}

  # 4.3.9. Check if three code points would start an ident sequence
  defp ident_start?("--" <> _), do: true
  defp ident_start?("-" <> rest), do: ident_start_code_point?(rest)
  defp ident_start?(name), do: ident_start_code_point?(name)

  defp ident_start_code_point?(<<c::utf8, _::binary>>)
       when c in ?a..?z or c in ?A..?Z or c == ?_ or c >= 0x80,
       do: true

  defp ident_start_code_point?("\\" <> _), do: true
  defp ident_start_code_point?(_), do: false

  # <nesting-selector> = '&'
  def nesting_selector([{:delim, "&"} | tokens]), do: {{:nesting, "&"}, tokens}
  def nesting_selector(tokens), do: {nil, tokens}

  @combinators %{
    ">" => :child_combinator,
    "+" => :sibling_combinator,
    "~" => :subsequent_combinator
  }

  # <combinator> = '>' | '+' | '~' | [ '|' '|' ], or whitespace alone for a descendant.
  def combinator(tokens) do
    case ignore_whitespace(tokens) do
      [{:delim, "|"}, {:delim, "|"} | rest] ->
        {{:column_combinator, "||"}, ignore_whitespace(rest)}

      [{:delim, delim} | rest] when is_map_key(@combinators, delim) ->
        {{@combinators[delim], delim}, ignore_whitespace(rest)}

      ^tokens ->
        {nil, tokens}

      rest ->
        {{:descendant_combinator, " "}, rest}
    end
  end

  # <ns-prefix> = [ <ident-token> | '*' ]? '|'
  def ns_prefix([{:ident, ident}, {:delim, "|"} | tokens]),
    do: {{:ns_prefix, "#{ident}|"}, tokens}

  def ns_prefix([{:delim, "*"}, {:delim, "|"} | tokens]),
    do: {{:ns_prefix, "*|"}, tokens}

  def ns_prefix([{:delim, "|"} | tokens]),
    do: {{:ns_prefix, "|"}, tokens}

  def ns_prefix(tokens), do: {nil, tokens}

  # <wq-name> = <ns-prefix>? <ident-token>
  def wq_name([{:ident, ident1}, {:delim, "|"}, {:ident, ident2} | tokens]),
    do: {{:wq_name, ident1 <> "|" <> ident2}, tokens}

  def wq_name([{:delim, "*"}, {:delim, "|"}, {:ident, ident} | tokens]),
    do: {{:wq_name, "*|" <> ident}, tokens}

  def wq_name([{:delim, "|"}, {:ident, ident} | tokens]),
    do: {{:wq_name, "|" <> ident}, tokens}

  def wq_name([{:ident, ident} | tokens]),
    do: {{:wq_name, ident}, tokens}

  def wq_name(tokens), do: {nil, tokens}

  # <attr-matcher> = [ '~' | '|' | '^' | '$' | '*' ]? '='
  @attr_matchers ~w[~ | ^ $ *]
  def attr_matcher([{:delim, delim}, {:delim, "="} | tokens]) when delim in @attr_matchers,
    do: {{:attr_matcher, delim <> "="}, tokens}

  def attr_matcher([{:delim, "="} | tokens]),
    do: {{:attr_matcher, "="}, tokens}

  def attr_matcher(tokens), do: {nil, tokens}

  # <attr-modifier> = i | s, ASCII case-insensitive
  @attr_modifiers ~w[i s I S]
  def attr_modifier([{:whitespace, _} | tokens]), do: attr_modifier(tokens)

  def attr_modifier([{:ident, ident} | tokens]) when ident in @attr_modifiers,
    do: {{:attr_modifier, ident}, tokens}

  def attr_modifier(tokens), do: {nil, tokens}

  # <type-selector> = <wq-name> | <ns-prefix>? '*'
  # A prefix and `*` first, as `html|*` would otherwise be the `html` alone.
  def type_selector(tokens) do
    case ns_prefix(tokens) do
      {{:ns_prefix, ns_prefix}, [{:delim, "*"} | rest]} -> {{:type, ns_prefix <> "*"}, rest}
      _ -> wq_name_or_universal(tokens)
    end
  end

  defp wq_name_or_universal(tokens) do
    case wq_name(tokens) do
      {{:wq_name, wq_name}, rest} -> {{:type, wq_name}, rest}
      {nil, [{:delim, "*"} | rest]} -> {{:universal, "*"}, rest}
      {nil, _tokens} -> {nil, tokens}
    end
  end

  # <pseudo-class-selector> = ':' <ident-token> |
  #                           ':' <function-token> <any-value> ')'
  def pseudo_class_selector([{:colon, _}, {:ident, ident} | tokens]),
    do: {{:pseudo_class, ":" <> ident}, tokens}

  def pseudo_class_selector([{:colon, _}, %Function{} = function | tokens] = all) do
    case pseudo_class_function(String.downcase(function.name), function) do
      {:ok, pseudo_class} -> {{:pseudo_class, pseudo_class}, tokens}
      :error -> {nil, all}
    end
  end

  def pseudo_class_selector(tokens), do: {nil, tokens}

  # :is() and :where() take a forgiving selector list, which drops the selectors that don't parse;
  # :not() a selector list; the :nth-*() pseudo-classes An+B, and :nth-child() and
  # :nth-last-child() a selector list after `of`. Selectors in them can't have pseudo-elements.
  # Any other function's arguments stay its component values.
  defp pseudo_class_function(name, %Function{name: original, value: value})
       when name in ["is", "where"],
       do: {:ok, %PseudoClass{name: original, selectors: forgiving_selector_list(value)}}

  defp pseudo_class_function("not", %Function{name: name, value: value}) do
    with {:ok, selectors} <- real_selector_list(value),
         do: {:ok, %PseudoClass{name: name, selectors: selectors}}
  end

  defp pseudo_class_function(name, %Function{name: original, value: value})
       when name in ["nth-child", "nth-last-child"] do
    with {{_, _} = an_b, rest} <- an_b(value),
         {:ok, selectors} <- of_selectors(ignore_whitespace(rest)) do
      {:ok, %PseudoClass{name: original, an_b: an_b, selectors: selectors}}
    else
      _ -> :error
    end
  end

  defp pseudo_class_function(name, %Function{name: original, value: value})
       when name in ["nth-of-type", "nth-last-of-type"] do
    with {{_, _} = an_b, rest} <- an_b(value),
         [] <- ignore_whitespace(rest) do
      {:ok, %PseudoClass{name: original, an_b: an_b}}
    else
      _ -> :error
    end
  end

  defp pseudo_class_function(_name, function), do: {:ok, function}

  defp of_selectors([]), do: {:ok, []}

  defp of_selectors([{:ident, of} | selectors]) do
    if String.downcase(of) == "of", do: real_selector_list(selectors), else: :error
  end

  defp of_selectors(_tokens), do: :error

  # <complex-real-selector-list>: all of it selectors, none with a pseudo-element.
  defp real_selector_list(tokens) do
    with {[_ | _] = selectors, rest} <- selector_list(tokens),
         [] <- ignore_whitespace(rest),
         false <- Enum.any?(selectors, &pseudo_element?/1) do
      {:ok, selectors}
    else
      _ -> :error
    end
  end

  # <forgiving-selector-list>: each selector between commas that parses.
  defp forgiving_selector_list(tokens) do
    tokens
    |> Enum.chunk_by(&match?({:comma, _}, &1))
    |> Enum.reject(&match?([{:comma, _} | _], &1))
    |> Enum.flat_map(fn selector ->
      case real_selector_list(selector) do
        {:ok, selectors} -> selectors
        :error -> []
      end
    end)
  end

  defp pseudo_element?({:pseudo_element, _}), do: true

  defp pseudo_element?(%{value: parts}) when is_list(parts),
    do: parts |> List.flatten() |> Enum.any?(&pseudo_element?/1)

  defp pseudo_element?(_part), do: false

  @doc """
  The [An+B microsyntax](https://www.w3.org/TR/css-syntax-3/#anb-microsyntax), `{a, b}`, as `2n+1`
  and `odd` are `{2, 1}`. It isn't a token of its own: `2n+1` is a dimension and a number, `n-1`
  an ident, `2n - 1` a dimension, a `-` and a number.
  """
  def an_b(tokens) do
    case an(ignore_whitespace(tokens)) do
      {:ok, a, b, rest} -> {{a, b}, rest}
      :error -> {nil, tokens}
    end
  end

  defp an(tokens) do
    case first_an_b(tokens) do
      {a, {:b, b}, rest} -> {:ok, a, b, rest}
      {a, :optional_b, rest} -> optional_b(a, rest)
      {a, :negative_b, rest} -> negative_b(a, ignore_whitespace(rest))
      :error -> :error
    end
  end

  # odd, even, an integer, or what has the n: a dimension with an integer, an ident, or `+` and an
  # ident with no whitespace between them.
  defp first_an_b([{:number, number} | rest]) do
    case integer(number) do
      {:ok, b} -> {0, {:b, b}, rest}
      :error -> :error
    end
  end

  defp first_an_b([{:dimension, [number, unit]} | rest]) do
    case integer(number) do
      {:ok, a} -> n(a, String.downcase(unit), rest)
      :error -> :error
    end
  end

  defp first_an_b([{:ident, ident} | rest]) do
    case String.downcase(ident) do
      "odd" -> {2, {:b, 1}, rest}
      "even" -> {2, {:b, 0}, rest}
      "-" <> n -> n(-1, n, rest)
      n -> n(1, n, rest)
    end
  end

  defp first_an_b([{:delim, "+"}, {:ident, ident} | rest]) do
    case String.downcase(ident) do
      "-" <> _ -> :error
      n -> n(1, n, rest)
    end
  end

  defp first_an_b(_tokens), do: :error

  # `n`, maybe followed by B; `n-`, followed by B without its sign; or `n-` and B's digits.
  defp n(a, "n", rest), do: {a, :optional_b, rest}
  defp n(a, "n-", rest), do: {a, :negative_b, rest}

  defp n(a, "n-" <> digits, rest) do
    case signless_integer(digits) do
      {:ok, b} -> {a, {:b, -b}, rest}
      :error -> :error
    end
  end

  defp n(_a, _n, _rest), do: :error

  # A signed integer, or `+` or `-` and a signless one; else B is 0.
  defp optional_b(a, rest) do
    case ignore_whitespace(rest) do
      [{:number, "+" <> _ = b} | more] -> signed_b(a, integer(b), more)
      [{:number, "-" <> _ = b} | more] -> signed_b(a, integer(b), more)
      [{:delim, "+"} | more] -> sign_b(a, 1, ignore_whitespace(more))
      [{:delim, "-"} | more] -> sign_b(a, -1, ignore_whitespace(more))
      _ -> {:ok, a, 0, rest}
    end
  end

  defp signed_b(a, {:ok, b}, rest), do: {:ok, a, b, rest}
  defp signed_b(_a, :error, _rest), do: :error

  defp sign_b(a, sign, [{:number, b} | rest]) do
    case signless_integer(b) do
      {:ok, b} -> {:ok, a, sign * b, rest}
      :error -> :error
    end
  end

  defp sign_b(_a, _sign, _tokens), do: :error

  defp negative_b(a, tokens), do: sign_b(a, -1, tokens)

  defp integer(text) do
    case Integer.parse(text) do
      {integer, ""} -> {:ok, integer}
      _ -> :error
    end
  end

  defp signless_integer(<<digit, _::binary>> = text) when digit in ?0..?9, do: integer(text)
  defp signless_integer(_text), do: :error

  @doc false
  def consume_pseudo_class_selectors(tokens, result \\ {:cont, []})
  def consume_pseudo_class_selectors(rest, {:halt, acc}), do: {Enum.reverse(acc), rest}

  def consume_pseudo_class_selectors(tokens, {:cont, acc}) do
    case pseudo_class_selector(tokens) do
      {{:pseudo_class, _} = token, rest} ->
        consume_pseudo_class_selectors(rest, {:cont, [token | acc]})

      {nil, _rest} ->
        consume_pseudo_class_selectors(tokens, {:halt, acc})
    end
  end

  @doc """
      <attribute-selector> = '[' <wq-name> ']' |
                    '[' <wq-name> <attr-matcher> [ <string-token> | <ident-token> ] <attr-modifier>? ']'
  """
  def attribute_selector([%SimpleBlock{terminator: :rbracket, value: value} | tokens] = all) do
    case attribute(value) do
      {:ok, attribute} -> {{:attribute, "[" <> attribute <> "]"}, tokens}
      :error -> {nil, all}
    end
  end

  def attribute_selector(tokens), do: {nil, tokens}

  defp attribute(tokens) do
    with {{:wq_name, name}, rest} <- wq_name(ignore_whitespace(tokens)),
         {:ok, match} <- attribute_match(ignore_whitespace(rest)) do
      {:ok, name <> match}
    else
      _ -> :error
    end
  end

  defp attribute_match([]), do: {:ok, ""}

  defp attribute_match(tokens) do
    with {{:attr_matcher, matcher}, rest} <- attr_matcher(tokens),
         [{type, value} | rest] when type in [:string, :ident] <- ignore_whitespace(rest),
         {modifier, rest} = attr_modifier(rest),
         [] <- ignore_whitespace(rest) do
      {:ok, matcher <> value <> modifier(modifier)}
    else
      _ -> :error
    end
  end

  defp modifier({:attr_modifier, modifier}), do: " " <> modifier
  defp modifier(nil), do: ""

  # <pseudo-element-selector> = ':' <pseudo-class-selector>
  def pseudo_element_selector([{:colon, _}, {:colon, _}, {:ident, ident} | tokens]),
    do: {{:pseudo_element, "::" <> ident}, tokens}

  def pseudo_element_selector([{:colon, _}, {:colon, _}, %Function{} = func | tokens]),
    do: {{:pseudo_element, func}, tokens}

  def pseudo_element_selector(tokens), do: {nil, tokens}

  @doc """
      <simple-selector> = <type-selector> | <subclass-selector>
  """
  def simple_selector(tokens) do
    case type_selector(tokens) do
      {{type, type_selector}, rest} ->
        {%SimpleSelector{type: type, value: type_selector}, rest}

      {nil, _rest} ->
        case subclass_selector(tokens) do
          {{type, subclass_selector}, rest} ->
            {%SimpleSelector{type: type, value: subclass_selector}, rest}

          {nil, _rest} ->
            {nil, tokens}
        end
    end
  end

  @doc """
      <compound-selector> = [ <type-selector>? <subclass-selector>*
                              [ <pseudo-element-selector> <pseudo-class-selector>* ]* ]!
  """
  def compound_selector(tokens) do
    {prelude_tokens, rest} = compound_prelude(tokens)
    {postlude_tokens, rest} = consume_compound_postlude(rest)

    case prelude_tokens ++ postlude_tokens do
      [] ->
        {nil, tokens}

      [%{} = compound_token] ->
        {compound_token, rest}

      [{type, value}] ->
        {%SimpleSelector{type: type, value: value}, rest}

      compound_tokens ->
        {%CompoundSelector{value: compound_tokens}, rest}
    end
  end

  defp compound_prelude(tokens) do
    case type_selector(tokens) do
      {{_, _} = type_token, rest} ->
        {subclass_selectors, rest} = consume_subclass_selectors(rest)
        {[type_token | subclass_selectors], rest}

      {nil, tokens} ->
        consume_subclass_selectors(tokens)
    end
  end

  defp compound_postlude(tokens) do
    case pseudo_element_selector(tokens) do
      {{:pseudo_element, _} = pseudo_element_token, rest} ->
        {pseudo_class_selectors, rest} = consume_pseudo_class_selectors(rest)
        {[pseudo_element_token | pseudo_class_selectors], rest}

      {nil, tokens} ->
        {nil, tokens}
    end
  end

  @doc false
  def consume_compound_postlude(tokens, result \\ {:cont, []})
  def consume_compound_postlude(rest, {:halt, acc}), do: {Enum.reverse(acc), rest}

  def consume_compound_postlude(tokens, {:cont, acc}) do
    case compound_postlude(tokens) do
      {nil, _rest} ->
        consume_compound_postlude(tokens, {:halt, acc})

      {postlude_tokens, rest} ->
        consume_compound_postlude(rest, {:cont, [postlude_tokens | acc]})
    end
  end

  @doc """
      <complex-selector> = <compound-selector> [ <combinator>? <compound-selector> ]*
  """
  def complex_selector(tokens) do
    case compound_selector(tokens) do
      {nil, _rest} ->
        {nil, tokens}

      {compound_selector, rest} ->
        {postlude, rest} = consume_complex_postlude(rest)

        if postlude == [] do
          {compound_selector, rest}
        else
          {%ComplexSelector{value: [compound_selector | postlude]}, rest}
        end
    end
  end

  # Compound selectors next to each other always have a combinator between them, whitespace at
  # least, as `a::before.b` doesn't.
  @doc false
  def complex_postlude(tokens) do
    with {{_, _} = combinator, rest} <- combinator(tokens),
         {%{} = compound_selector, rest} <- compound_selector(rest) do
      {[combinator, compound_selector], rest}
    else
      _ -> {nil, tokens}
    end
  end

  @doc false
  def consume_complex_postlude(tokens, result \\ {:cont, []})
  def consume_complex_postlude(rest, {:halt, acc}), do: {Enum.reverse(acc), rest}

  def consume_complex_postlude(tokens, {:cont, acc}) do
    case complex_postlude(tokens) do
      {nil, _rest} ->
        consume_complex_postlude(tokens, {:halt, acc})

      {complex_postlude, rest} ->
        consume_complex_postlude(rest, {:cont, [complex_postlude | acc]})
    end
  end

  @doc """
      <relative-selector> = <combinator>? <complex-selector>

  A complex selector, its first compound selector after its combinator, as `> a` is
  `%ComplexSelector{value: [[{:child_combinator, ">"}, a]]}`.
  """
  def relative_selector(tokens) do
    case combinator(tokens) do
      {{type, _} = combinator, rest} when type != :descendant_combinator ->
        relative(combinator, complex_selector(rest), tokens)

      _ ->
        complex_selector(ignore_whitespace(tokens))
    end
  end

  defp relative(_combinator, {nil, _rest}, tokens), do: {nil, tokens}

  defp relative(combinator, {%ComplexSelector{value: [first | postlude]}, rest}, _tokens),
    do: {%ComplexSelector{value: [[combinator, first] | postlude]}, rest}

  defp relative(combinator, {compound_selector, rest}, _tokens),
    do: {%ComplexSelector{value: [[combinator, compound_selector]]}, rest}

  @doc """
      <subclass-selector> = <id-selector> | <class-selector> |
                            <attribute-selector> | <pseudo-class-selector>

  and the `&` nesting selector.
  """
  def subclass_selector(tokens) do
    Enum.find_value(
      [
        &id_selector/1,
        &class_selector/1,
        &attribute_selector/1,
        &pseudo_class_selector/1,
        &nesting_selector/1
      ],
      {nil, tokens},
      fn parse ->
        case parse.(tokens) do
          {nil, _tokens} -> nil
          found -> found
        end
      end
    )
  end

  @doc false
  def consume_subclass_selectors(tokens, result \\ {:cont, []})
  def consume_subclass_selectors(rest, {:halt, acc}), do: {Enum.reverse(acc), rest}

  def consume_subclass_selectors(tokens, {:cont, acc}) do
    case subclass_selector(tokens) do
      {{_, _} = token, rest} ->
        consume_subclass_selectors(rest, {:cont, [token | acc]})

      {nil, _rest} ->
        consume_subclass_selectors(tokens, {:halt, acc})
    end
  end

  @doc """
  The `<declaration-value>` production matches any sequence of one or more tokens, so long as the
  sequence does not contain `<bad-string-token>`, `<bad-url-token>`, unmatched `<)-token>`,
  `<]-token>`, or `<}-token>`, or top-level `<semicolon-token>` tokens or `<delim-token>` tokens with
  a value of `"!"`. It represents the entirety of what a valid declaration can have as its value.
  """
  def declaration_value([%Function{} = token | rest]), do: {{:declaration_value, token}, rest}

  def declaration_value(tokens) do
    {declaration_tokens, rest} =
      Enum.split_while(tokens, fn
        {:bad_url, _} -> false
        {:bad_string, _} -> false
        {:rparen, _} -> false
        {:rbracket, _} -> false
        {:rcurly, _} -> false
        {:delim, "!"} -> false
        _ -> true
      end)

    {{:declaration_value, declaration_tokens |> Enum.map(&value/1) |> Enum.join("")}, rest}
  end

  @doc false
  def value(%Function{} = function), do: function
  def value({_, x}), do: x
end
