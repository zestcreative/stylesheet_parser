defmodule CssTokenizer do
  @moduledoc """
  Documentation for `CssTokenizer`.
  """
  alias __MODULE__.Tokenizer

  def tokenize(css) do
    {:ok, tokens, _, _, _, _} =
      css
      |> preprocess()
      |> Tokenizer.consume()

    {:ok, tokens}
  end

  # https://www.w3.org/TR/css-syntax-3/#input-preprocessing
  # Convert to Unix line endings.
  defp preprocess(css) do
    css
    |> String.replace("\f", "\n")
    |> String.replace("\r\n", "\n")
    |> String.replace("\r", "\n")
  end
end
