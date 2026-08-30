# Usage Rules for ExNumerlo

These rules provide guidance for LLM agents and developers when using the `ExNumerlo` library.

## Core Principles

- **Single Entry Point:** Always use `ExNumerlo.convert/2` for all operations (encoding, decoding, and cross-system conversion).
- **Strict Error Tuples:** Every public interaction returns `{:ok, result}` or `{:error, reason}`. There are no throwing variants.
- **Intelligent Auto-Detection:** Source systems are auto-detected by default (`from: :auto`). To decode a string to an Elixir integer, use `ExNumerlo.convert(encoded_string, to: :integer)`.

## System Specifics and Constraints

### Historical Systems
- **Positive Integers Only (> 0):** `:roman`, `:attic`, `:aegean`, `:egyptian`, `:ethiopic`, `:brahmi`.
- **Non-Negative Integers (>= 0):** `:mayan`, `:cuneiform`, `:kaktovik`.
- **Roman Range:** `:roman` is limited to `1..3999`.

### Sinhala
- **Sinhala Lith:** Use `:sinhala` for base-10 Sinhala digits (U+0DE6–0DEF). Digits are unique, so auto-detection works.


### Specialized Systems
- **Duodecimal:** Use `:duodecimal` for base-12. Auto-detection requires unique digits (↊ or ↋).
- **Mathematical Styles:** positional styles `:math_bold`, `:math_double_struck`, `:math_monospace`, `:math_sans`, and `:math_sans_bold`.

### Programmer Bases
- **Binary/Octal/Hexadecimal/Base32/Base36:** Use `:binary` (base-2), `:octal` (base-8), `:hexadecimal` (base-16), `:base32` (base-32, digits 0-9 and A-V), and `:base36` (base-36, digits 0-9 and A-Z).
- **Auto-Detection:** `:hexadecimal` auto-detects when a string contains A-F letters. `:base32` auto-detects when a string contains a letter in G..V (A-F or digits alone resolve to `:hexadecimal`/`:arabic`). `:base36` auto-detects when a string contains a letter in W..Z. `:binary` and `:octal` share the ASCII digit set with `:arabic`, so without unique digits they auto-detect as `:arabic`; pass `from:` explicitly to disambiguate.

### Formatting Features
- **Separators:** Supported only for positional systems via the `:separator` option.
- **Sign Handling:** Positional systems support `+` and `-` prefixes during decoding.

## Implementation Patterns

### Encoding and Decoding
```elixir
# Encode
{:ok, "१२३"} = ExNumerlo.convert(123, to: :devanagari)

# Decode
{:ok, 123} = ExNumerlo.convert("MMXXVI", to: :integer)

# Batch
{:ok, ["I", "II"]} = ExNumerlo.convert([1, 2], to: :roman)
```

## Naming Conventions
- **System Atoms:** Always use lowercase atoms (e.g., `:thai`, `:mayan`).
- **Integer Target:** Always use `to: :integer` for decoding to Elixir integers.
