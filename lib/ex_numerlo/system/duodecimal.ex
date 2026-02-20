defmodule ExNumerlo.System.Duodecimal do
  @moduledoc false
  @behaviour ExNumerlo.System

  @base_digits Enum.to_list(0x0030..0x0039) ++ [0x218A, 0x218B]
  @radix 12

  @impl ExNumerlo.System
  def encode(number, opts \\ []) when is_integer(number) do
    separator = Keyword.get(opts, :separator)
    abs_number = abs(number)

    encoded =
      abs_number
      |> Integer.digits(@radix)
      |> Enum.map(fn d -> Enum.at(@base_digits, d) end)
      |> apply_separator(separator)
      |> List.to_string()
      |> prepend_sign(number)

    {:ok, encoded}
  end

  defp apply_separator(digits, nil), do: digits
  defp apply_separator(digits, ""), do: digits

  defp apply_separator(digits, sep) do
    [sep_cp | _] = String.to_charlist(sep)

    digits
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.intersperse([sep_cp])
    |> List.flatten()
    |> Enum.reverse()
  end

  defp prepend_sign(string, n) when n < 0, do: "-" <> string
  defp prepend_sign(string, _), do: string

  @impl ExNumerlo.System
  def decode(string, opts \\ []) do
    chars = String.to_charlist(string)
    separator = Keyword.get(opts, :separator)

    chars
    |> strip_sign()
    |> maybe_strip_separator(separator)
    |> Enum.reduce_while({:ok, 0}, fn cp, {:ok, acc} ->
      case find_digit(cp) do
        {:ok, digit} -> {:cont, {:ok, acc * @radix + digit}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
    |> apply_sign(chars)
  end

  defp find_digit(cp) do
    case Enum.find_index(@base_digits, &(&1 == cp)) do
      nil -> {:error, :invalid_digit}
      idx -> {:ok, idx}
    end
  end

  defp strip_sign([?+ | rest]), do: rest
  defp strip_sign([?- | rest]), do: rest
  defp strip_sign(rest), do: rest

  defp apply_sign({:ok, val}, [?- | _]), do: {:ok, -val}
  defp apply_sign(res, _chars), do: res

  defp maybe_strip_separator(list, nil), do: list
  defp maybe_strip_separator(list, ""), do: list

  defp maybe_strip_separator(list, sep) do
    [sep_cp | _] = String.to_charlist(sep)
    Enum.reject(list, fn cp -> cp == sep_cp end)
  end

  @impl ExNumerlo.System
  def detect?(string) do
    chars =
      string
      |> String.to_charlist()
      |> strip_sign()
      |> Enum.reject(&Enum.member?([?,, ?., ?\s], &1))

    case chars do
      [] ->
        false

      _ ->
        Enum.all?(chars, &Enum.member?(@base_digits, &1)) and
          Enum.any?(chars, &Enum.member?([0x218A, 0x218B], &1))
    end
  end
end
