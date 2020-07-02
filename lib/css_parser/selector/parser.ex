defmodule CssParser.Selector.Parser do
  @moduledoc """
  https://www.w3.org/TR/selectors-4/

  <selector-list> = <complex-selector-list>
  <complex-selector-list> = <complex-selector>#
  <compound-selector-list> = <compound-selector>#
  <simple-selector-list> = <simple-selector>#
  <relative-selector-list> = <relative-selector>#

  <complex-selector> = <compound-selector> [ <combinator>? <compound-selector> ]*
  <relative-selector> = <combinator>? <complex-selector>
  <compound-selector> = [ <type-selector>? <subclass-selector>*
                          [ <pseudo-element-selector> <pseudo-class-selector>* ]* ]!
  <simple-selector> = <type-selector> | <subclass-selector>

  """

  defmodule ParseError do
    defexception [:message, :remaining_tokens]
  end

  defmodule ComplexSelector do
    defstruct []
  end

  defmodule RelativeSelector do
    defstruct []
  end

  defmodule CompoundSelector do
    defstruct []
  end

  defmodule SimpleSelector do
    defstruct []
  end

  defmodule TypeSelector do
    defstruct []
  end

  defmodule SubclassSelector do
    defstruct []
  end

  defmodule IdSelector do
    defstruct []
  end

  defmodule ClassSelector do
    defstruct []
  end

  defmodule AttributeSelector do
    defstruct []
  end

  defmodule PseudoClassSelector do
    defstruct []
  end

  defmodule PseudoElementSelector do
    defstruct []
  end

  # <class-selector> = '.' <ident-token>
  def class_selector([{:delim, "."}, {:ident, ident} | tokens]),
    do: {{:class_selector, ".#{ident}"}, tokens}
  def class_selector(tokens), do: {nil, tokens}

  # <id-selector> = <hash-token>
  def id_selector([{:hash, id} | tokens]), do: {{:id_selector, id}, tokens}
  def id_selector(tokens), do: {nil, tokens}

  # <combinator> = '>' | '+' | '~' | [ '|' '|' ]
  @combinators ~w[> | - +]
  def combinator([{:delim, "|"}, {:delim, "|"} | tokens]),
    do: {{:combinator, "||"}, tokens}
  def combinator([{:delim, delim} | tokens]) when delim in @combinators,
    do: {{:combinator, delim}, tokens}
  def combinator(_), do: nil

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
    do: {{:wq_name, "#{ident1}|#{ident2}"}, tokens}
  def wq_name([{:delim, "*"}, {:delim, "|"}, {:ident, ident} | tokens]),
    do: {{:wq_name, "*|#{ident}"}, tokens}
  def wq_name([{:delim, "|"}, {:ident, ident} | tokens]),
    do: {{:wq_name, "|#{ident}"}, tokens}
  def wq_name([{:ident, ident} | tokens]),
    do: {{:wq_name, "#{ident}"}, tokens}
    def wq_name(tokens), do: {nil, tokens}

  # <attr-matcher> = [ '~' | '|' | '^' | '$' | '*' ]? '='
  @attr_matchers ~w[~ | ^ $ *]
  def attr_matcher([{:delim, delim}, {:delim, "="} | tokens]) when delim in @attr_matchers,
    do: {{:attr_matcher, "#{delim}="}, tokens}
  def attr_matcher([{:delim, "="} | tokens]),
    do: {{:attr_matcher, "="}, tokens}
  def attr_matcher(tokens), do: {nil, tokens}

  @attr_modifiers ~w[i s]
  # i = case-insensitive
  # s = case-sensitive
  def attr_modifier([{:delim, delim} | tokens]) when delim in @attr_modifiers,
    do: {{:attr_modifier, "="}, tokens}
  def attr_modifier(tokens), do: {nil, tokens}

  # <type-selector> = <wq-name> | <ns-prefix>? '*'
  def type_selector(tokens) do
    with {nil, wq_tokens} <- wq_name(tokens) do
      case ns_prefix(wq_tokens) do
        {{:ns_prefix, ns_prefix}, [{:delim, "*"} | ns_tokens]} ->
          {{:type_selector, "#{ns_prefix}*"}, ns_tokens}
        {nil, [{:delim, "*"} | ns_tokens]} ->
          {{:type_selector, "*"}, ns_tokens}
        _ ->
          {nil, tokens}
      end
    end
  end

  # <pseudo-class-selector> = ':' <ident-token> |
  #                           ':' <function-token> <any-value> ')'
  def pseudo_class_selector([{:colon, _}, {:ident, ident} | tokens]),
    do: {{:pseudo_class_selector, ident}, tokens}
  def pseudo_class_selector([{:colon, _}, {:function, func} | rest] = tokens) do
    case any_value(rest) do
      {{:any_value, any}, [{:rparen, _} | rest]} ->
        {{:pseudo_class_selector, ":#{func}#{any}"}, rest}
      _ ->
        {nil, tokens}
    end
  end

  @doc """
  <attribute-selector> = '[' <wq-name> ']' |
                '[' <wq-name> <attr-matcher> [ <string-token> | <ident-token> ] <attr-modifier>? ']'
  """
  def attribute_selector([{:lbracket, _} | tokens]) do
    case wq_name(tokens) do
      {{:wq_name, wq_name}, [{:rbracket, _} | rest]} ->
        {{:attribute_selector, "[#{wq_name}]"}, rest}
      {{:wq_name, wq_name}, rest} ->
        case attr_matcher(rest) do
          {{:attr_matcher, attr_matcher}, rest} ->

          _ ->
            {nil, tokens}
        end
        {{:attribute_selector, "[#{wq_name}]"}, rest}
      _ ->
        {nil, tokens}

    end
  end

  # <pseudo-element-selector> = ':' <pseudo-class-selector>
  def pseudo_element_selector([{:colon, _} | tokens]) do
    case pseudo_class_selector(tokens) do
      {{:pseudo_class_selector, pseudo}, rest} ->
        {{:pseudo_element_selector, ":#{pseudo}"}, rest}
      _ ->
        {nil, tokens}
    end
  end

  @doc """
  <subclass-selector> = <id-selector> | <class-selector> |
                        <attribute-selector> | <pseudo-class-selector>
  """
  def subclass_selector(tokens) do
    cond do
      {{:id_selector, selector}, rest} = id_selector(tokens) ->
        {{:subclass_selector, selector}, rest}
      {{:class_selector, selector}, rest} = class_selector(tokens) ->
        {{:subclass_selector, selector}, rest}
      {{:attribute_selector, selector}, rest} = attribute_selector(tokens) ->
        {{:subclass_selector, selector}, rest}
      {{:pseudo_class_selector, selector}, rest} = pseudo_class_selector(tokens) ->
        {{:subclass_selector, selector}, rest}
      true ->
        {nil, tokens}
    end
  end

  @doc """
  The `<declaration-value>` production matches any sequence of one or more tokens, so long as the
  sequence does not contain `<bad-string-token>`, `<bad-url-token>`, unmatched `<)-token>`,
  `<]-token>`, or <}-token>, or top-level `<semicolon-token>` tokens or `<delim-token>` tokens with
  a value of `"!"`. It represents the entirety of what a valid declaration can have as its value.
  """
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

    {{:declaration_value, declaration_tokens |> Enum.map(& elem(&1, 1)) |> Enum.join("")}, rest}
  end

  @doc """
  The `<any-value>` production is identical to `<declaration-value>`, but also allows top-level
  `<semicolon-token>` tokens and `<delim-token>` tokens with a value of `"!"`. It represents the
  entirety of what valid CSS can be in any context.
  """
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

    {{:any_value, any_tokens |> Enum.map(& elem(&1, 1)) |> Enum.join("")}, rest}
  end
end
