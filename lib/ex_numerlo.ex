defmodule ExNumerlo do
  @moduledoc """
  ExNumerlo provides a unified interface for rendering and parsing integers using various Unicode numeral systems.
  """

  alias ExNumerlo.System

  @typedoc "Supported numeral systems."
  @type system ::
          :arabic
          | :arabic_indic
          | :extended_arabic_indic
          | :devanagari
          | :bengali
          | :gurmukhi
          | :gujarati
          | :oriya
          | :tamil
          | :telugu
          | :kannada
          | :malayalam
          | :thai
          | :lao
          | :tibetan
          | :burmese
          | :khmer
          | :mongolian
          | :fullwidth
          | :math_monospace
          | :math_bold
          | :math_double_struck
          | :math_sans
          | :math_sans_bold
          | :roman
          | :aegean
          | :attic
          | :mayan
          | :ethiopic
          | :cuneiform
          | :duodecimal

  # Ordered for auto-detection. More specific/unique systems first.
  @all_systems [
    # Historical/Complex (Unique glyphs)
    :aegean,
    :attic,
    :mayan,
    :ethiopic,
    :cuneiform,
    :roman,
    # Specialized/Math
    :math_bold,
    :math_double_struck,
    :math_sans,
    :math_sans_bold,
    :math_monospace,
    :fullwidth,
    # Modern Positional
    :thai,
    :lao,
    :tibetan,
    :burmese,
    :khmer,
    :mongolian,
    :devanagari,
    :bengali,
    :gurmukhi,
    :gujarati,
    :oriya,
    :tamil,
    :telugu,
    :kannada,
    :malayalam,
    # Arabic and its direct variants
    :arabic,
    :arabic_indic,
    :extended_arabic_indic,
    # Duodecimal is VERY greedy if it overlaps with Arabic
    :duodecimal
  ]

  @doc """
  Lists all supported numeral systems with descriptions and points of interest.

  ## Positional Systems (Base-10)
  - `:arabic`: Standard Western Arabic numerals (0-9).
  - `:arabic_indic`: Numerals used in much of the Arabic world (distinct from Western 'Arabic').
  - `:extended_arabic_indic`: Eastern Arabic-Indic numerals (Persian/Urdu variant).
  - `:devanagari`: Direct ancestors of the modern Indo-Arabic numeral system.
  - `:bengali`, `:gurmukhi`, `:gujarati`, `:oriya`, `:tamil`, `:telugu`, `:kannada`, `:malayalam`:
    Various Brahmic scripts of South Asia.
  - `:thai`, `:lao`, `:tibetan`, `:burmese`, `:khmer`, `:mongolian`:
    Standard positional systems for their respective scripts.
  - `:fullwidth`: Fixed-width forms used in CJK contexts for alignment.

  ## Mathematical Alphanumeric (Base-10)
  - `:math_bold`, `:math_double_struck`, `:math_monospace`, `:math_sans`, `:math_sans_bold`:
    Positional styles for mathematical notation.

  ## Specialized & Historical
  - `:duodecimal`: Base-12 system using Pitman's notation (↊ for 10, ↋ for 11). 
    Auto-detection requires at least one unique digit to distinguish from Arabic.
  - `:roman`: Standard Roman numerals (range 1-3999). 
    Uses additive/subtractive notation (e.g., XIV for 14).
  - `:aegean`: Used by Minoan and Mycenaean civilizations (Linear A/B). 
    Purely additive system with symbols for powers of ten (1 to 10,000).
  - `:attic`: Ancient Greek acrophonic system. 
    Symbols are derived from the first letter of their name (e.g., Δ for Deka/10).
  - `:mayan`: Vigesimal (base-20) positional system. 
    Features a shell for zero, dots for units, and bars for fives.
  - `:ethiopic`: Hierarchical additive-multiplicative system. 
    Uses segments of 100 and a 10,000 multiplier (፼).
  - `:cuneiform`: Babylonian sexagesimal (base-60) positional system. 
    Internal digits (1-59) are additive using vertical and horizontal wedges.
  """
  @spec systems() :: [system()]
  def systems, do: @all_systems

  @doc """
  Converts an input (integer, list of integers, or encoded string) to another numeral system.

  ## Options
    - `:to` - Target system (default: `:arabic`). Use `:integer` to decode to an Elixir integer.
    - `:from` - Source system (default: `:auto`).
    - `:separator` - Separator to use for encoding/decoding.

  ## Examples
      iex> ExNumerlo.convert(123, to: :devanagari)
      {:ok, "१२३"}

      iex> ExNumerlo.convert("१२३", to: :roman)
      {:ok, "CXXIII"}

      iex> ExNumerlo.convert([1, 2, 3], to: :roman)
      {:ok, ["I", "II", "III"]}

      iex> ExNumerlo.convert("MMXXVI", to: :integer)
      {:ok, 2026}
  """
  @spec convert(integer() | [integer()] | String.t(), keyword()) ::
          {:ok, String.t() | [String.t()] | integer()} | {:error, term()}
  def convert(input, opts \\ [])

  def convert(numbers, opts) when is_list(numbers) do
    target_system = Keyword.get(opts, :to, :arabic)

    numbers
    |> Enum.reduce_while({:ok, []}, fn n, {:ok, acc} ->
      case convert(n, to: target_system) do
        {:ok, res} -> {:cont, {:ok, [res | acc]}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
    |> case do
      {:ok, list} -> {:ok, Enum.reverse(list)}
      error -> error
    end
  end

  def convert(input, opts) when is_integer(input) do
    target_system = Keyword.get(opts, :to, :arabic)

    case system_module(target_system) do
      nil -> {:error, :unknown_system}
      module -> module.encode(input, opts)
    end
  end

  def convert(input, opts) when is_binary(input) do
    source_system = Keyword.get(opts, :from, :auto)
    target_system = Keyword.get(opts, :to, :arabic)

    with {:ok, value} <- do_decode(input, source_system, opts) do
      case target_system do
        :integer -> {:ok, value}
        _ -> convert(value, to: target_system)
      end
    end
  end

  defp do_decode(string, :auto, opts) do
    @all_systems
    |> Enum.find(fn sys ->
      case system_module(sys) do
        nil -> false
        module -> module.detect?(string)
      end
    end)
    |> case do
      nil -> {:error, :unknown_system}
      sys -> do_decode(string, sys, opts)
    end
  end

  defp do_decode(string, system, opts) do
    case system_module(system) do
      nil -> {:error, :unknown_system}
      module -> module.decode(string, opts)
    end
  end

  defp system_module(:arabic), do: System.Arabic
  defp system_module(:arabic_indic), do: System.ArabicIndic
  defp system_module(:extended_arabic_indic), do: System.ExtendedArabicIndic
  defp system_module(:devanagari), do: System.Devanagari
  defp system_module(:bengali), do: System.Bengali
  defp system_module(:gurmukhi), do: System.Gurmukhi
  defp system_module(:gujarati), do: System.Gujarati
  defp system_module(:oriya), do: System.Oriya
  defp system_module(:tamil), do: System.Tamil
  defp system_module(:telugu), do: System.Telugu
  defp system_module(:kannada), do: System.Kannada
  defp system_module(:malayalam), do: System.Malayalam
  defp system_module(:thai), do: System.Thai
  defp system_module(:lao), do: System.Lao
  defp system_module(:tibetan), do: System.Tibetan
  defp system_module(:burmese), do: System.Burmese
  defp system_module(:khmer), do: System.Khmer
  defp system_module(:mongolian), do: System.Mongolian
  defp system_module(:fullwidth), do: System.Fullwidth
  defp system_module(:math_bold), do: System.MathBold
  defp system_module(:math_double_struck), do: System.MathDoubleStruck
  defp system_module(:math_sans), do: System.MathSans
  defp system_module(:math_sans_bold), do: System.MathSansBold
  defp system_module(:math_monospace), do: System.MathMonospace
  defp system_module(:roman), do: System.Roman
  defp system_module(:aegean), do: System.Historical.Aegean
  defp system_module(:attic), do: System.Historical.Attic
  defp system_module(:mayan), do: System.Historical.Mayan
  defp system_module(:ethiopic), do: System.Historical.Ethiopic
  defp system_module(:cuneiform), do: System.Historical.Cuneiform
  defp system_module(:duodecimal), do: System.Duodecimal
  defp system_module(_), do: nil
end
