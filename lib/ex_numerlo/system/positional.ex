defmodule ExNumerlo.System.Positional do
  @moduledoc false
  defmacro __using__(opts) do
    base_cp = Keyword.fetch!(opts, :base)
    system_base = Keyword.get(opts, :radix, 10)

    quote do
      @behaviour ExNumerlo.System
      @base_cp unquote(base_cp)
      @radix unquote(system_base)

      @impl ExNumerlo.System
      def encode(number, opts \\ []) when is_integer(number) do
        separator = Keyword.get(opts, :separator)

        encoded =
          number
          |> abs()
          |> Integer.digits(@radix)
          |> Enum.map(fn d -> d + @base_cp end)
          |> apply_separator(separator)
          |> List.to_string()
          |> prepend_sign(number)

        {:ok, encoded}
      end

      defp apply_separator(digits, nil), do: digits
      defp apply_separator(digits, ""), do: digits

      defp apply_separator(digits, sep) do
        [sep_cp | _] = String.to_charlist(sep)

        # We reverse the digits to group from the least significant digit (right-to-left)
        # then reverse back to restore the original order with separators.
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
          case cp - @base_cp do
            digit when digit >= 0 and digit < @radix ->
              {:cont, {:ok, acc * @radix + digit}}

            _ ->
              {:halt, {:error, :invalid_digit}}
          end
        end)
        |> apply_sign(chars)
      end

      # We handle both + and - signs here to be robust during parsing.
      defp strip_sign([?+ | rest]), do: rest
      defp strip_sign([?- | rest]), do: rest
      defp strip_sign(rest), do: rest

      # If the original charlist started with a negative sign, we negate the result.
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
        string
        |> String.to_charlist()
        |> strip_sign()
        # We reject common punctuation to allow detection of formatted numbers
        # even when the specific separator isn't provided to the detector.
        |> Enum.reject(&Enum.member?([?,, ?., ?\s], &1))
        |> case do
          [] ->
            false

          chars ->
            Enum.all?(chars, fn cp ->
              digit = cp - @base_cp
              digit >= 0 and digit < @radix
            end)
        end
      end
    end
  end
end
