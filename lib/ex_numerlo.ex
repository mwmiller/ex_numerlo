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

  @systems_metadata %{
    # Historical/Complex
    aegean: %{
      description: "Aegean numerals used by Minoan and Mycenaean civilizations (Linear A/B).",
      base: 10,
      type: :additive,
      range: :positive
    },
    attic: %{
      description: "Ancient Greek acrophonic system where symbols derive from number names.",
      base: 10,
      type: :additive,
      range: :positive
    },
    mayan: %{
      description: "Vigesimal (base-20) positional system with shell for zero, dots, and bars.",
      base: 20,
      type: :positional,
      range: :non_negative
    },
    ethiopic: %{
      description: "Ge'ez hierarchical additive-multiplicative system using segments of 100.",
      base: 10,
      type: :hybrid,
      range: :positive
    },
    cuneiform: %{
      description: "Babylonian sexagesimal (base-60) positional system using wedges.",
      base: 60,
      type: :positional,
      range: :non_negative
    },
    roman: %{
      description: "Standard Roman numerals using additive/subtractive notation.",
      base: 10,
      type: :additive,
      range: 1..3999
    },
    # Specialized
    duodecimal: %{
      description: "Base-12 system using Pitman's notation (↊ for 10, ↋ for 11).",
      base: 12,
      type: :positional,
      range: :all
    },
    fullwidth: %{
      description: "Fixed-width forms of Arabic numerals used in CJK contexts.",
      base: 10,
      type: :positional,
      range: :all
    },
    # Math
    math_bold: %{
      description: "Mathematical bold serif digits.",
      base: 10,
      type: :positional,
      range: :all
    },
    math_double_struck: %{
      description: "Mathematical blackboard bold digits.",
      base: 10,
      type: :positional,
      range: :all
    },
    math_monospace: %{
      description: "Mathematical fixed-width digits.",
      base: 10,
      type: :positional,
      range: :all
    },
    math_sans: %{
      description: "Mathematical sans-serif digits.",
      base: 10,
      type: :positional,
      range: :all
    },
    math_sans_bold: %{
      description: "Mathematical bold sans-serif digits.",
      base: 10,
      type: :positional,
      range: :all
    },
    # Modern Positional
    arabic: %{
      description: "Standard Western Arabic numerals (0-9).",
      base: 10,
      type: :positional,
      range: :all
    },
    arabic_indic: %{
      description: "Standard Arabic-Indic numerals.",
      base: 10,
      type: :positional,
      range: :all
    },
    extended_arabic_indic: %{
      description: "Eastern Arabic-Indic numerals (Persian/Urdu).",
      base: 10,
      type: :positional,
      range: :all
    },
    devanagari: %{
      description: "Numerals used with the Devanagari script.",
      base: 10,
      type: :positional,
      range: :all
    },
    bengali: %{
      description: "Bengali-Assamese numerals.",
      base: 10,
      type: :positional,
      range: :all
    },
    gurmukhi: %{
      description: "Gurmukhi (Punjabi) script numerals.",
      base: 10,
      type: :positional,
      range: :all
    },
    gujarati: %{
      description: "Gujarati script numerals.",
      base: 10,
      type: :positional,
      range: :all
    },
    oriya: %{
      description: "Oriya (Odia) script numerals.",
      base: 10,
      type: :positional,
      range: :all
    },
    tamil: %{
      description: "Tamil script numerals.",
      base: 10,
      type: :positional,
      range: :all
    },
    telugu: %{
      description: "Telugu script numerals.",
      base: 10,
      type: :positional,
      range: :all
    },
    kannada: %{
      description: "Kannada script numerals.",
      base: 10,
      type: :positional,
      range: :all
    },
    malayalam: %{
      description: "Malayalam script numerals.",
      base: 10,
      type: :positional,
      range: :all
    },
    thai: %{
      description: "Thai script numerals.",
      base: 10,
      type: :positional,
      range: :all
    },
    lao: %{
      description: "Lao script numerals.",
      base: 10,
      type: :positional,
      range: :all
    },
    tibetan: %{
      description: "Tibetan script numerals.",
      base: 10,
      type: :positional,
      range: :all
    },
    burmese: %{
      description: "Burmese script numerals.",
      base: 10,
      type: :positional,
      range: :all
    },
    khmer: %{
      description: "Khmer script numerals.",
      base: 10,
      type: :positional,
      range: :all
    },
    mongolian: %{
      description: "Traditional Mongolian script numerals.",
      base: 10,
      type: :positional,
      range: :all
    }
  }

  # This list defines the priority for auto-detection.
  # More specific systems (unique glyphs) are checked first to prevent
  # false positives in more generic systems (like standard digits).
  @all_systems [
    # Unique/Complex glyphs take priority
    :aegean,
    :attic,
    :mayan,
    :ethiopic,
    :cuneiform,
    :roman,
    # Specialized digits
    :math_bold,
    :math_double_struck,
    :math_sans,
    :math_sans_bold,
    :math_monospace,
    :fullwidth,
    # Standard script digits
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
    # Generic digits last
    :arabic,
    :arabic_indic,
    :extended_arabic_indic,
    :duodecimal
  ]

  @doc """
  Returns metadata for all supported numeral systems.

  ## Examples
      iex> ExNumerlo.systems()[:roman]
      %{base: 10, description: "Standard Roman numerals using additive/subtractive notation.", range: 1..3999, type: :additive}

      iex> %{mayan: %{base: base}} = ExNumerlo.systems()
      iex> base
      20
  """
  @spec systems() :: %{system() => map()}
  def systems, do: @systems_metadata

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

    # We use reduce_while here to ensure we stop immediately
    # if any element in the list fails to encode.
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
    # During auto-detection, we check systems in @all_systems order
    # to prioritize more specific systems over generic ones.
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
