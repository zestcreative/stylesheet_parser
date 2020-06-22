defmodule CssTokenizer.Stylesheet do
  defstruct [rules: []]

  defmodule AtRule do
    defstruct [prelude: [], :name, :value, :block]
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
    %__MODULE__{}
  end

end
