defmodule CssParser do
  @moduledoc """
  Documentation for `CssParser`.
  """

  alias __MODULE__.{Tokenizer, Parser}

  @doc """
  Intended to be the normal parser entry point, for parsing stylesheets.
  """
  def parse_stylesheet(css) when is_binary(css) do
    with {:ok, tokens} <- tokenize(css) do
      Parser.parse_stylesheet(tokens)
    end
  end

  @doc """
  Intended for the content of at-rules such as @media. It differs from `parse_stylesheet/1` in the
  handling of <CDO-token> and <CDC-token>.
  """
  def parse_rules(css) when is_binary(css) do
    with {:ok, tokens} <- tokenize(css) do
      Parser.parse_rules(tokens)
    end
  end

  @doc """
  Intended for use by the CSSStyleSheet#insertRule method, and similar functions which might exist,
  which parse text into a single rule.
  """
  def parse_rule(css) when is_binary(css) do
    with {:ok, tokens} <- tokenize(css) do
      Parser.parse_rule(tokens)
    end
  end

  @doc """
  Used in `@supports` conditions. [CSS3-CONDITIONAL](https://www.w3.org/TR/css3-conditional/)
  """
  def parse_declaration(css) when is_binary(css) do
    with {:ok, tokens} <- tokenize(css) do
      Parser.parse_declaration(tokens)
    end
  end

  @doc """
  Used for the contents of a style attribute, which parses text into the contents of a single style
  rule.
  """
  def parse_declarations(css) when is_binary(css) do
    with {:ok, tokens} <- tokenize(css) do
      Parser.parse_declarations(tokens)
    end
  end

  @doc """
  Used for things that need to consume a single value, like the parsing rules for `attr()`.
  """
  def parse_component_value(css) when is_binary(css) do
    with {:ok, tokens} <- tokenize(css) do
      Parser.parse_component_value(tokens)
    end
  end

  @doc """
  Used for the contents of presentational attributes, which parse text into a single declaration’s
  value, or for parsing a stand-alone selector [SELECT](https://www.w3.org/TR/selectors-3/) or list
  of Media Queries [MEDIAQ](https://www.w3.org/TR/mediaqueries-4/), as in Selectors API or the media
  HTML attribute.
  """
  def parse_component_values(css) when is_binary(css) do
    with {:ok, tokens} <- tokenize(css) do
      Parser.parse_component_values(tokens)
    end
  end

  @doc false
  def tokenize(css) do
    {:ok, tokens, _, _, _, _} = Tokenizer.consume(css)
    {:ok, tokens}
  end
end
