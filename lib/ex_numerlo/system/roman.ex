defmodule ExNumerlo.System.Roman do
  @moduledoc false
  @behaviour ExNumerlo.System

  @max_roman 3999

  # Standard Roman numerals are additive and subtractive.
  # We use a descending list to greedily match the largest possible symbol.
  @roman_mapping [
    {1000, "M"},
    {900, "CM"},
    {500, "D"},
    {400, "CD"},
    {100, "C"},
    {90, "XC"},
    {50, "L"},
    {40, "XL"},
    {10, "X"},
    {9, "IX"},
    {5, "V"},
    {4, "IV"},
    {1, "I"}
  ]

  @impl ExNumerlo.System
  def encode(number, opts \\ [])

  def encode(number, _opts) when is_integer(number) and number > 0 and number <= @max_roman,
    do: {:ok, do_to_roman(number, @roman_mapping)}

  def encode(number, _opts) when is_integer(number) and number > @max_roman,
    do: {:error, :out_of_range}

  def encode(number, _opts) when is_integer(number),
    do: {:error, :not_positive}

  defp do_to_roman(0, _), do: ""

  defp do_to_roman(n, [{val, symbol} | _rest] = mapping) when n >= val,
    do: symbol <> do_to_roman(n - val, mapping)

  defp do_to_roman(n, [_ | rest]), do: do_to_roman(n, rest)

  @impl ExNumerlo.System
  def decode(string, _opts \\ []) do
    string
    |> String.to_charlist()
    |> do_from_roman()
  end

  # We use recursive pattern matching to consume Roman symbols from left to right.
  # Subtractive pairs (like CM) take precedence over single symbols (like C).
  defp do_from_roman([]), do: {:ok, 0}
  defp do_from_roman([?M | rest]), do: add_to_roman(rest, 1000)
  defp do_from_roman([?C, ?M | rest]), do: add_to_roman(rest, 900)
  defp do_from_roman([?D | rest]), do: add_to_roman(rest, 500)
  defp do_from_roman([?C, ?D | rest]), do: add_to_roman(rest, 400)
  defp do_from_roman([?C | rest]), do: add_to_roman(rest, 100)
  defp do_from_roman([?X, ?C | rest]), do: add_to_roman(rest, 90)
  defp do_from_roman([?L | rest]), do: add_to_roman(rest, 50)
  defp do_from_roman([?X, ?L | rest]), do: add_to_roman(rest, 40)
  defp do_from_roman([?X | rest]), do: add_to_roman(rest, 10)
  defp do_from_roman([?I, ?X | rest]), do: add_to_roman(rest, 9)
  defp do_from_roman([?V | rest]), do: add_to_roman(rest, 5)
  defp do_from_roman([?I, ?V | rest]), do: add_to_roman(rest, 4)
  defp do_from_roman([?I | rest]), do: add_to_roman(rest, 1)
  defp do_from_roman(_), do: {:error, :invalid_roman_numeral}

  defp add_to_roman(rest, val) do
    case do_from_roman(rest) do
      {:ok, rest_val} -> {:ok, val + rest_val}
      error -> error
    end
  end

  @impl ExNumerlo.System
  def detect?(string) do
    string
    |> String.to_charlist()
    |> case do
      [] -> false
      chars -> Enum.all?(chars, &Enum.member?([?I, ?V, ?X, ?L, ?C, ?D, ?M], &1))
    end
  end
end
