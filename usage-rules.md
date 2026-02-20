# Usage Rules for ExNumerlo

These rules provide guidance for LLM agents and developers when using the `ExNumerlo` library.

## Core Principles

- **Single Entry Point:** Always use `ExNumerlo.convert/2` for all operations (encoding, decoding, and cross-system conversion).
- **Strict Error Tuples:** Every public interaction returns `{:ok, result}` or `{:error, reason}`. There are no throwing variants.
- **Intelligent Auto-Detection:** Source systems are auto-detected by default (`from: :auto`). To decode a string to an Elixir integer, use `ExNumerlo.convert(encoded_string, to: :integer)`.

## System Specifics and Constraints

### Historical Systems
- **Positive Integers Only (> 0):** `:roman`, `:attic`, `:aegean`, `:ethiopic`.
- **Non-Negative Integers (>= 0):** `:mayan`, `:cuneiform`.
- **Roman Range:** `:roman` is limited to `1..3999`.

### Specialized Systems
- **Duodecimal:** Use `:duodecimal` for base-12. Auto-detection requires unique digits (↊ or ↋).
- **Mathematical Styles:** positional styles `:math_bold`, `:math_double_struck`, `:math_monospace`, `:math_sans`, and `:math_sans_bold`.

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
