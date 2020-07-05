defmodule CssParser.Selector.Parser do
  @moduledoc """
  https://www.w3.org/TR/selectors-4/
  """

  alias CssParser.{Function, SimpleSelector, CompoundSelector, ComplexSelector}

  @doc """
  <selector-list> = <complex-selector-list>
  <complex-selector-list> = <complex-selector>#
  """
  def selector_list(tokens, result \\ {:cont, []})
  def selector_list(rest, {:halt, acc}), do: {Enum.reverse(acc), rest}
  def selector_list(tokens, {:cont, acc}) do
    case complex_selector(tokens) do
      {nil, rest} ->
        selector_list(rest, {:halt, acc})
      {complex_selector, [{:comma, ","} | rest]} ->
        rest = ignore_whitespace(rest)
        selector_list(rest, {:cont, [complex_selector | acc]})
      {complex_selector, rest} ->
        selector_list(rest, {:halt, [complex_selector | acc]})
    end
  end

  @doc """
  <compound-selector-list> = <compound-selector>#
  """
  def compound_selector_list(tokens, result \\ {:cont, []})
  def compound_selector_list(rest, {:halt, acc}), do: {Enum.reverse(acc), rest}
  def compound_selector_list(tokens, {:cont, acc}) do
    case compound_selector(tokens) do
      {nil, rest} ->
        compound_selector_list(rest, {:halt, acc})
      {compound_selector, [{:comma, ","} | rest]} ->
        rest = ignore_whitespace(rest)
        compound_selector_list(rest, {:cont, [compound_selector | acc]})
      {compound_selector, rest} ->
        compound_selector_list(rest, {:halt, [compound_selector | acc]})
    end
  end

  @doc """
  <simple-selector-list> = <simple-selector>#
  """
  def simple_selector_list(tokens, result \\ {:cont, []})
  def simple_selector_list(rest, {:halt, acc}), do: {Enum.reverse(acc), rest}
  def simple_selector_list(tokens, {:cont, acc}) do
    case simple_selector(tokens) do
      {nil, rest} ->
        simple_selector_list(rest, {:halt, acc})
      {simple_selector, [{:comma, ","} | rest]} ->
        rest = ignore_whitespace(rest)
        simple_selector_list(rest, {:cont, [simple_selector | acc]})
      {simple_selector, rest} ->
        simple_selector_list(rest, {:halt, [simple_selector | acc]})
    end
  end

  @doc """
  <relative-selector-list> = <relative-selector>#
  """
  def relative_selector_list(tokens, result \\ {:cont, []})
  def relative_selector_list(rest, {:halt, acc}), do: {Enum.reverse(acc), rest}
  def relative_selector_list(tokens, {:cont, acc}) do
    case relative_selector(tokens) do
      {{:relative, relative_selector}, [{:comma, ","} | rest]} ->
        rest = ignore_whitespace(rest)
        relative_selector_list(rest, {:cont, [relative_selector | acc]})
      {{:relative, relative_selector}, rest} ->
        relative_selector_list(rest, {:halt, [relative_selector | acc]})
      {nil, rest} ->
        relative_selector_list(rest, {:halt, acc})
    end
  end

  def ignore_whitespace([{:whitespace, _} | rest]), do: rest
  def ignore_whitespace(tokens), do: tokens

  # <class-selector> = '.' <ident-token>
  def class_selector([{:delim, "."}, {:ident, ident} | tokens]),
    do: {{:class, ".#{ident}"}, tokens}
  def class_selector(tokens), do: {nil, tokens}

  # <id-selector> = <hash-token>
  def id_selector([{:hash, id} | tokens]), do: {{:id, id}, tokens}
  def id_selector(tokens), do: {nil, tokens}

  def combinator([{:delim, "|"}, {:delim, "|"} | rest]) do
    rest = ignore_whitespace(rest)
    {{:column_combinator, "||"}, rest}
  end
  def combinator([{:whitespace, _}, {:delim, "|"}, {:delim, "|"} | rest]) do
    rest = ignore_whitespace(rest)
    {{:column_combinator, "||"}, rest}
  end

  def combinator([{:delim, ">"} | rest]) do
    rest = ignore_whitespace(rest)
    {{:child_combinator, ">"}, rest}
  end

  def combinator([{:whitespace, _}, {:delim, ">"} | rest]) do
    rest = ignore_whitespace(rest)
    {{:child_combinator, ">"}, rest}
  end

  def combinator([{:delim, "+"} | rest]) do
    rest = ignore_whitespace(rest)
    {{:sibling_combinator, "+"}, rest}
  end

  def combinator([{:whitespace, _}, {:delim, "+"} | rest]) do
    rest = ignore_whitespace(rest)
    {{:sibling_combinator, "+"}, rest}
  end

  def combinator([{:delim, "~"} | rest]) do
    rest = ignore_whitespace(rest)
    {{:subsequent_combinator, "~"}, rest}
  end
  def combinator([{:whitespace, _}, {:delim, "~"} | rest]) do
    rest = ignore_whitespace(rest)
    {{:subsequent_combinator, "~"}, rest}
  end

  def combinator([{:whitespace, _} | rest]),
    do: {{:descendant_combinator, " "}, rest}

  def combinator(tokens), do: {nil, tokens}

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

  @attr_modifiers ~w[i s]
  # i = case-insensitive
  # s = case-sensitive
  def attr_modifier([{:whitespace, _} | tokens]), do: attr_modifier(tokens)
  def attr_modifier([{:ident, ident} | tokens]) when ident in @attr_modifiers,
    do: {{:attr_modifier, ident}, tokens}
  def attr_modifier(tokens), do: {nil, tokens}

  # <type-selector> = <wq-name> | <ns-prefix>? '*'
  def type_selector(tokens) do
    case wq_name(tokens) do
      {{:wq_name, wq_name}, rest} ->
        {{:type, wq_name}, rest}
      {nil, rest} ->
        case ns_prefix(rest) do
          {{:ns_prefix, ns_prefix}, [{:delim, "*"} | rest]} ->
            {{:type, ns_prefix <> "*"}, rest}
          {nil, [{:delim, "*"} | rest]} ->
            {{:universal, "*"}, rest}
          _ ->
            {nil, tokens}
        end
    end
  end

  # <pseudo-class-selector> = ':' <ident-token> |
  #                           ':' <function-token> <any-value> ')'
  def pseudo_class_selector([{:colon, _}, {:ident, ident} | tokens]),
    do: {{:pseudo_class, ":" <> ident}, tokens}
  def pseudo_class_selector([{:colon, _}, %Function{} = func | tokens]),
    do: {{:pseudo_class, func}, tokens}
  def pseudo_class_selector([{:colon, _} | rest] = tokens) do
    case any_value(rest) do
      {{:any_value, any}, [{:rparen, _} | rest]} ->
        {{:pseudo_class, ":" <> any}, rest}
      _ ->
        {nil, tokens}
    end
  end
  def pseudo_class_selector(tokens), do: {nil, tokens}

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
  def attribute_selector([{:lbracket, _} | rest] = tokens) do
    case wq_name(rest) do
      {{:wq_name, wq_name}, [{:rbracket, _} | rest]} ->
        {{:attribute, "[" <> wq_name <> "]"}, rest}

      {{:wq_name, wq_name}, rest} ->
        case attr_matcher(rest) do
          {{:attr_matcher, attr_matcher}, [{:string, string} | rest]} ->
            case attr_modifier(rest) do
              {{:attr_modifier, attr_modifier}, [{:rbracket, _} | rest]} ->
                {{:attribute, "[" <> wq_name <> attr_matcher <> string <> " " <> attr_modifier <> "]"}, rest}
              {nil, [{:rbracket, _} | rest]} ->
                {{:attribute, "[" <> wq_name <> attr_matcher <> string <> "]"}, rest}
            end

          {{:attr_matcher, attr_matcher}, rest} ->
            {{:attribute, "[" <> wq_name <> attr_matcher <> "]"}, rest}

          _ ->
            {nil, tokens}
        end

      _ ->
        {nil, tokens}
    end
  end
  def attribute_selector(tokens), do: {nil, tokens}

  # <pseudo-element-selector> = ':' <pseudo-class-selector>
  def pseudo_element_selector([{:colon, _} | tokens]) do
    case pseudo_class_selector(tokens) do
      {{:pseudo_class, pseudo}, rest} ->
        {{:pseudo_element, ":" <> pseudo}, rest}
      _ ->
        {nil, tokens}
    end
  end
  def pseudo_element_selector(tokens), do: {nil, tokens}


  @doc """
  <simple-selector> = <type-selector> | <subclass-selector>
  """
  def simple_selector(tokens) do
    case type_selector(tokens) do
      {{_, type_selector}, rest} ->
        {%SimpleSelector{value: type_selector}, rest}

      {nil, _rest} ->
        case subclass_selector(tokens) do
          {{_, subclass_selector}, rest} ->
            {%SimpleSelector{value: subclass_selector}, rest}
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

  def complex_postlude(tokens) do
    {combinator_token, rest} = combinator(tokens)

    case compound_selector(rest) do
      {nil, _rest} ->
        {nil, tokens}

      {compound_selector, rest} ->
        result = if combinator_token,
          do: [combinator_token, compound_selector],
          else: [compound_selector]
        {result, rest}
    end
  end

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
  """
  def relative_selector(tokens) do
    {combinator, rest} = combinator(tokens)
    case complex_selector(rest) do
      {nil, rest} ->
        {nil, rest}

      {complex_selector, rest} ->
        result = if combinator,
          do: [combinator | complex_selector],
        else: complex_selector
          {{:relative_selector, result}, rest}

    end
  end

  @doc """
  <subclass-selector> = <id-selector> | <class-selector> |
                        <attribute-selector> | <pseudo-class-selector>
  """
  def subclass_selector(tokens) do
    cond do
      match?({{:id, _}, _}, id_selector(tokens)) ->
        id_selector(tokens)
      match?({{:class, _}, _}, class_selector(tokens)) ->
        class_selector(tokens)
      match?({{:attribute, _}, _}, attribute_selector(tokens)) ->
        attribute_selector(tokens)
      match?({{:pseudo_class, _}, _}, pseudo_class_selector(tokens)) ->
        pseudo_class_selector(tokens)
      true ->
        {nil, tokens}
    end
  end

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
  `<]-token>`, or <}-token>, or top-level `<semicolon-token>` tokens or `<delim-token>` tokens with
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

  @doc """
  The `<any-value>` production is identical to `<declaration-value>`, but also allows top-level
  `<semicolon-token>` tokens and `<delim-token>` tokens with a value of `"!"`. It represents the
  entirety of what valid CSS can be in any context.
  """
  def any_value([%Function{} = token | rest]), do: {{:any_value, token}, rest}
  def any_value(tokens) do
    {any_tokens, rest} =
      Enum.split_while(tokens, fn
        {:bad_url, _} -> false
        {:bad_string, _} -> false
        {:rparen, _} -> false
        {:rbracket, _} -> false
        {:rcurly, _} -> false
        _ -> true
      end)

    {{:any_value, any_tokens |> Enum.map(&value/1) |> Enum.join("")}, rest}
  end

  def value(%Function{} = function), do: function
  def value({_, x}), do: x
end
