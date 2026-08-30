defmodule ExNumerlo.System.Programmer do
  @moduledoc false

  defmacro __using__(opts) do
    base = Keyword.fetch!(opts, :base)
    digits = Keyword.fetch!(opts, :digits)
    unique_digits = Keyword.get(opts, :unique_digits, [])

    quote do
      @behaviour ExNumerlo.System
      @base unquote(base)
      @digits unquote(digits)
      @unique_digits unquote(unique_digits)

      @impl ExNumerlo.System
      def encode(number, opts \\ []) when is_integer(number) do
        separator = Keyword.get(opts, :separator)

        encoded =
          number
          |> abs()
          |> Integer.digits(@base)
          |> Enum.map(fn d -> Enum.at(@digits, d) end)
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
            {:ok, digit} -> {:cont, {:ok, acc * @base + digit}}
            {:error, reason} -> {:halt, {:error, reason}}
          end
        end)
        |> apply_sign(chars)
      end

      defp find_digit(cp) do
        case Enum.find_index(@digits, &(&1 == cp)) do
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
            Enum.all?(chars, &Enum.member?(@digits, &1)) and
              (match?([], @unique_digits) or Enum.any?(chars, &Enum.member?(@unique_digits, &1)))
        end
      end
    end
  end
end

defmodule ExNumerlo.System.Binary do
  @moduledoc false
  use ExNumerlo.System.Programmer, base: 2, digits: ~c"01"
end

defmodule ExNumerlo.System.Octal do
  @moduledoc false
  use ExNumerlo.System.Programmer, base: 8, digits: ~c"01234567"
end

defmodule ExNumerlo.System.Hexadecimal do
  @moduledoc false
  use ExNumerlo.System.Programmer,
    base: 16,
    digits: ~c"0123456789ABCDEF",
    unique_digits: ~c"ABCDEF"
end

defmodule ExNumerlo.System.Base32 do
  @moduledoc false
  use ExNumerlo.System.Programmer,
    base: 32,
    digits: ~c"0123456789ABCDEFGHIJKLMNOPQRSTUV",
    unique_digits: ~c"ABCDEFGHIJKLMNOPQRSTUV"
end

defmodule ExNumerlo.System.Base36 do
  @moduledoc false
  use ExNumerlo.System.Programmer,
    base: 36,
    digits: ~c"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    unique_digits: ~c"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
end
