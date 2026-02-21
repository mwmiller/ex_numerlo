# ExNumerlo

ExNumerlo is an Elixir library for rendering and parsing integers using various Unicode numeral systems. It supports over 50 different scripts, including modern positional systems, historical additive and hybrid systems, and specialized mathematical representations.

## Features

- **Unified API:** One function (`ExNumerlo.convert/2`) for all your conversion needs.
- **Auto-Detection:** Intelligent source system detection for easy decoding.
- **Broad Support:** From Western Arabic to ancient Mayan and Kaktovik Iñupiaq numerals.
- **Formatted Input:** Support for separators (e.g., thousands separators) in positional systems.

Add `ex_numerlo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_numerlo, "~> 0.1.0"}
  ]
end
```

## Usage

The sole public interface is `ExNumerlo.convert/2`, which handles encoding, decoding, and cross-system conversion.

### Encoding Integers

To encode an integer (or a list of integers) into a specific numeral system:

```elixir
ExNumerlo.convert(123, to: :devanagari)
# {:ok, "१२३"}

ExNumerlo.convert(2026, to: :roman)
# {:ok, "MMXXVI"}

ExNumerlo.convert([1, 2, 3], to: :roman)
# {:ok, ["I", "II", "III"]}
```

### Decoding Strings

To decode an encoded string back to an integer, use the `to: :integer` option. You can specify the source system or let it be auto-detected:

```elixir
# Explicit source
ExNumerlo.convert("१२३", from: :devanagari, to: :integer)
# {:ok, 123}

# Auto-detection
ExNumerlo.convert("MMXXVI", to: :integer)
# {:ok, 2026}
```

### Separator Support

Positional systems support custom separators for grouping:

```elixir
ExNumerlo.convert(1234567, to: :arabic, separator: ",")
# {:ok, "1,234,567"}

ExNumerlo.convert("1.234.567", from: :arabic, to: :integer, separator: ".")
# {:ok, 1234567}
```

### Supported Systems

The following systems are currently supported:

*   **Modern Positional:** `:arabic`, `:arabic_indic`, `:extended_arabic_indic`, `:devanagari`, `:bengali`, `:gurmukhi`, `:gujarati`, `:oriya`, `:tamil`, `:telugu`, `:kannada`, `:malayalam`, `:thai`, `:lao`, `:tibetan`, `:burmese`, `:khmer`, `:mongolian`, `:adlam`, `:balinese`, `:chakma`, `:cham`, `:gunjala_gondi`, `:javanese`, `:kayah_li`, `:lepcha`, `:limbu`, `:masaram_gondi`, `:meetei_mayek`, `:modi`, `:mro`, `:n_ko`, `:new_tai_lue`, `:nyiakeng_puachue_hmong`, `:ol_chiki`, `:osmanya`, `:pahawh_hmong`, `:saurashtra`, `:sharada`, `:sora_sompeng`, `:sundanese`, `:tai_tham_hora`, `:tai_tham_tham`, `:takri`, `:tangsa`, `:tirhuta`, `:toto`, `:vai`, `:wancho`, `:warang_citi`, `:fullwidth`
*   **Historical:** `:roman` (1..3999), `:aegean`, `:attic`, `:mayan` (base-20), `:ethiopic`, `:cuneiform` (base-60), `:brahmi`, `:kaktovik` (base-20)
*   **Specialized:** `:duodecimal` (base-12 using ↊ and ↋), `:math_bold`, `:math_double_struck`, `:math_sans`, `:math_sans_bold`, `:math_monospace`


## LLM Agent Instructions

Usage rules for LLM agents are provided in `usage-rules.md` for integration with the `usage_rules` tool.
