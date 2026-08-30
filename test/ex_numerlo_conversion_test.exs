defmodule ExNumerloConversionTest do
  use ExUnit.Case

  @systems [
    :arabic,
    :devanagari,
    :thai,
    :fullwidth,
    :math_bold,
    :math_double_struck,
    :math_monospace,
    :roman,
    :aegean,
    :attic,
    :mayan,
    :duodecimal,
    :sinhala,
    :binary,
    :octal,
    :hexadecimal
  ]

  describe "round-trip conversions" do
    test "encodes and decodes back to the original value for all systems" do
      numbers = [1, 10, 42, 123, 2026]

      for sys <- @systems, n <- numbers do
        case ExNumerlo.convert(n, to: sys) do
          {:ok, encoded} ->
            {:ok, decoded} = ExNumerlo.convert(encoded, from: sys, to: :integer)

            assert decoded == n,
                   "Round-trip failed for #{sys} with #{n}: got #{decoded}, expected #{n} (encoded: #{inspect(encoded)})"

          _ ->
            :ok
        end
      end
    end

    test "auto-detection round-trip for 2026 in various systems" do
      test_cases = [
        {:arabic, "2026"},
        {:devanagari, "२०२६"},
        {:roman, "MMXXVI"},
        {:mayan, "𝋥𝋡𝋦"}
      ]

      for {sys, encoded} <- test_cases do
        {:ok, decoded} = ExNumerlo.convert(encoded, to: :integer)
        assert decoded == 2026, "Auto-detect failed for #{sys}: got #{decoded}"
      end
    end
  end

  describe "separator support" do
    test "groups digits with a custom separator" do
      {:ok, encoded} = ExNumerlo.convert(1_234_567, to: :arabic, separator: ",")
      assert encoded == "1,234,567"

      {:ok, decoded} = ExNumerlo.convert("1,234,567", from: :arabic, to: :integer, separator: ",")
      assert decoded == 1_234_567
    end

    test "applies separators to non-ASCII positional systems" do
      {:ok, devanagari} = ExNumerlo.convert(1000, to: :devanagari, separator: ".")
      assert devanagari == "१.०००"
    end
  end

  describe "duodecimal" do
    test "uses ↊ for 10 and ↋ for 11" do
      assert {:ok, "↊"} == ExNumerlo.convert(10, to: :duodecimal)
      assert {:ok, "↋"} == ExNumerlo.convert(11, to: :duodecimal)
      assert {:ok, "10"} == ExNumerlo.convert(12, to: :duodecimal)

      # ↋↋ is 11*12 + 11 = 132 + 11 = 143.
      assert {:ok, 143} == ExNumerlo.convert("↋↋", from: :duodecimal, to: :integer)
    end
  end

  describe "error handling with tuples" do
    test "returns errors for unknown and invalid inputs" do
      assert {:error, :unknown_system} == ExNumerlo.convert("abc", to: :integer)
      assert {:error, :invalid_digit} == ExNumerlo.convert("12A", from: :arabic, to: :integer)
    end
  end
end
