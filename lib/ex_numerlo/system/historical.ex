defmodule ExNumerlo.System.Historical do
  @moduledoc false

  defmodule Aegean do
    @moduledoc false
    @behaviour ExNumerlo.System

    @mapping [
      {10_000, 0x1012B},
      {1000, 0x10122},
      {100, 0x10119},
      {10, 0x10110},
      {1, 0x10107}
    ]

    @impl ExNumerlo.System
    def encode(n, opts \\ [])
    def encode(n, _opts) when is_integer(n) and n > 0, do: {:ok, encode_aegean(n, @mapping)}
    def encode(n, _opts) when is_integer(n), do: {:error, :not_positive}

    defp encode_aegean(0, _), do: ""

    defp encode_aegean(n, [{val, base_cp} | rest]) when n >= val do
      count = div(n, val)
      remainder = rem(n, val)
      # Aegean numerals use distinct glyphs for multiples of powers of ten
      # (e.g., 1-9 are 0x10107 to 0x1010F).
      List.to_string([base_cp + count - 1]) <> encode_aegean(remainder, rest)
    end

    defp encode_aegean(n, [_ | rest]), do: encode_aegean(n, rest)

    @impl ExNumerlo.System
    def decode(string, _opts \\ []) do
      string
      |> String.to_charlist()
      |> Enum.reduce_while({:ok, 0}, fn cp, {:ok, acc} ->
        case find_value(cp) do
          {:ok, val} -> {:cont, {:ok, acc + val}}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)
    end

    defp find_value(cp) when cp >= 0x1012B and cp <= 0x10133,
      do: {:ok, (cp - 0x1012B + 1) * 10_000}

    defp find_value(cp) when cp >= 0x10122 and cp <= 0x1012A, do: {:ok, (cp - 0x10122 + 1) * 1000}
    defp find_value(cp) when cp >= 0x10119 and cp <= 0x10121, do: {:ok, (cp - 0x10119 + 1) * 100}
    defp find_value(cp) when cp >= 0x10110 and cp <= 0x10118, do: {:ok, (cp - 0x10110 + 1) * 10}
    defp find_value(cp) when cp >= 0x10107 and cp <= 0x1010F, do: {:ok, cp - 0x10107 + 1}
    defp find_value(_), do: {:error, :invalid_aegean_numeral}

    @impl ExNumerlo.System
    def detect?(string) do
      chars = String.to_charlist(string)
      not_empty?(chars) and Enum.all?(chars, &aegean_digit?(&1))
    end

    defp not_empty?([]), do: false
    defp not_empty?(_), do: true

    defp aegean_digit?(cp) do
      case find_value(cp) do
        {:ok, _} -> true
        _ -> false
      end
    end
  end

  defmodule Attic do
    @moduledoc false
    @behaviour ExNumerlo.System

    @mapping [
      {50_000, 0x10147},
      {10_000, 0x039C},
      {5000, 0x10146},
      {1000, 0x03A7},
      {500, 0x10145},
      {100, 0x0397},
      {50, 0x10144},
      {10, 0x0394},
      {5, 0x10143},
      {1, 0x0399}
    ]

    @impl ExNumerlo.System
    def encode(n, opts \\ [])
    def encode(n, _opts) when is_integer(n) and n > 0, do: {:ok, do_encode(n, @mapping)}
    def encode(n, _opts) when is_integer(n), do: {:error, :not_positive}

    defp do_encode(0, _), do: ""

    defp do_encode(n, [{val, cp} | _rest] = mapping) when n >= val do
      # Attic Greek is acrophonic and additive. We consume symbols
      # from largest to smallest.
      List.to_string([cp]) <> do_encode(n - val, mapping)
    end

    defp do_encode(n, [_ | rest]), do: do_encode(n, rest)

    @impl ExNumerlo.System
    def decode(string, _opts \\ []) do
      string
      |> String.to_charlist()
      |> Enum.reduce_while({:ok, 0}, fn cp, {:ok, acc} ->
        case find_attic_value(cp) do
          {:ok, val} -> {:cont, {:ok, acc + val}}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)
    end

    defp find_attic_value(cp) do
      @mapping
      |> Enum.find(fn {_, v} -> v == cp end)
      |> case do
        {val, _} -> {:ok, val}
        nil -> {:error, :invalid_attic_numeral}
      end
    end

    @impl ExNumerlo.System
    def detect?(string) do
      case String.to_charlist(string) do
        [] -> false
        chars -> Enum.all?(chars, fn cp -> match?({:ok, _}, find_attic_value(cp)) end)
      end
    end
  end

  defmodule Mayan do
    @moduledoc false
    @behaviour ExNumerlo.System

    @impl ExNumerlo.System
    def encode(n, opts \\ [])

    def encode(n, _opts) when is_integer(n) and n >= 0 do
      # Mayan is a positional base-20 system.
      encoded =
        n
        |> Integer.digits(20)
        |> Enum.map_join(fn d -> List.to_string([0x1D2E0 + d]) end)

      {:ok, encoded}
    end

    def encode(n, _opts) when is_integer(n), do: {:error, :negative}

    @impl ExNumerlo.System
    def decode(string, _opts \\ []) do
      string
      |> String.to_charlist()
      |> Enum.reduce_while({:ok, 0}, fn cp, {:ok, acc} ->
        # Mayan digits 0-19 are contiguous in the Unicode block.
        case cp >= 0x1D2E0 and cp <= 0x1D2F3 do
          true -> {:cont, {:ok, acc * 20 + (cp - 0x1D2E0)}}
          false -> {:halt, {:error, :invalid_mayan_numeral}}
        end
      end)
    end

    @impl ExNumerlo.System
    def detect?(string) do
      case String.to_charlist(string) do
        [] ->
          false

        chars ->
          Enum.all?(chars, fn cp -> cp >= 0x1D2E0 and cp <= 0x1D2F3 end)
      end
    end
  end

  defmodule Ethiopic do
    @moduledoc false
    @behaviour ExNumerlo.System

    @impl ExNumerlo.System
    def encode(n, opts \\ [])
    def encode(n, _opts) when is_integer(n) and n > 0, do: {:ok, do_to_ethiopic(n)}
    def encode(n, _opts) when is_integer(n), do: {:error, :not_positive}

    defp do_to_ethiopic(0), do: ""

    defp do_to_ethiopic(n) when n >= 10_000 do
      p_str =
        case div(n, 10_000) do
          1 -> ""
          p -> encode_small(p)
        end

      p_str <> List.to_string([0x137C]) <> do_to_ethiopic(rem(n, 10_000))
    end

    defp do_to_ethiopic(n) when n >= 100 do
      p_str =
        case div(n, 100) do
          1 -> ""
          p -> encode_small(p)
        end

      p_str <> List.to_string([0x137B]) <> do_to_ethiopic(rem(n, 100))
    end

    defp do_to_ethiopic(n), do: encode_small(n)

    defp encode_small(n) do
      t_str =
        case div(n, 10) do
          0 -> ""
          tens -> List.to_string([0x1372 + tens - 1])
        end

      o_str =
        case rem(n, 10) do
          0 -> ""
          ones -> List.to_string([0x1369 + ones - 1])
        end

      t_str <> o_str
    end

    @impl ExNumerlo.System
    def decode(string, _opts \\ []) do
      string
      |> String.to_charlist()
      |> do_decode(0, 0, 0)
    end

    # Ethiopic uses a complex hierarchical structure with segment closers
    # for 100 (፻) and 10,000 (፼).
    # base_acc: accumulates the value within the current block (0-9999)
    # total: accumulates blocks of 10,000^N
    # current: accumulates value within base-100 (0-99)
    defp do_decode([], current, base_acc, total), do: {:ok, total + base_acc + current}

    defp do_decode([0x137C | rest], current, base_acc, total) do
      segment = base_acc + current

      coeff =
        case segment do
          0 -> 1
          s -> s
        end

      # ፼ (10,000) multiplies EVERYTHING that came before it in the current
      # power-of-10,000 segment.
      do_decode(rest, 0, 0, (total + coeff) * 10_000)
    end

    defp do_decode([0x137B | rest], current, base_acc, total) do
      coeff =
        case current do
          0 -> 1
          c -> c
        end

      # ፻ (100) multiplies only the current 0-99 part.
      do_decode(rest, 0, base_acc + coeff * 100, total)
    end

    defp do_decode([cp | rest], current, base_acc, total) when cp >= 0x1372 and cp <= 0x137A do
      do_decode(rest, current + (cp - 0x1372 + 1) * 10, base_acc, total)
    end

    defp do_decode([cp | rest], current, base_acc, total) when cp >= 0x1369 and cp <= 0x1371 do
      do_decode(rest, current + (cp - 0x1369 + 1), base_acc, total)
    end

    defp do_decode(_, _, _, _), do: {:error, :invalid_ethiopic_numeral}

    @impl ExNumerlo.System
    def detect?(string) do
      case String.to_charlist(string) do
        [] ->
          false

        chars ->
          Enum.all?(chars, fn cp ->
            cp >= 0x1369 and cp <= 0x137C
          end)
      end
    end
  end

  defmodule Cuneiform do
    @moduledoc false
    @behaviour ExNumerlo.System

    @impl ExNumerlo.System
    def encode(n, opts \\ [])

    def encode(n, _opts) when is_integer(n) and n >= 0 do
      # Babylonian Cuneiform is a positional base-60 system.
      # We use double spaces to separate sexagesimal place values
      # to make them legible.
      encoded =
        n
        |> Integer.digits(60)
        |> Enum.map_join("  ", &encode_digit/1)

      {:ok, encoded}
    end

    def encode(n, _opts) when is_integer(n), do: {:error, :negative}

    defp encode_digit(0), do: " "

    defp encode_digit(d) do
      # Within each base-60 digit, values are represented additively
      # using tens (𒌋) and units (𒁹).
      String.duplicate(List.to_string([0x1230B]), div(d, 10)) <>
        String.duplicate(List.to_string([0x12079]), rem(d, 10))
    end

    @impl ExNumerlo.System
    def decode(string, _opts \\ []) do
      # We split by our chosen double-space separator to parse each
      # sexagesimal digit individually.
      string
      |> String.split("  ")
      |> Enum.reduce_while({:ok, 0}, fn part, {:ok, acc} ->
        case decode_digit(String.to_charlist(part)) do
          {:ok, val} -> {:cont, {:ok, acc * 60 + val}}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)
    end

    defp decode_digit([?\s]), do: {:ok, 0}
    defp decode_digit([]), do: {:ok, 0}

    defp decode_digit(chars) do
      chars
      |> Enum.reduce_while({:ok, 0}, fn
        0x1230B, {:ok, acc} -> {:cont, {:ok, acc + 10}}
        0x12079, {:ok, acc} -> {:cont, {:ok, acc + 1}}
        _, _ -> {:halt, {:error, :invalid_cuneiform_numeral}}
      end)
    end

    @impl ExNumerlo.System
    def detect?(string) do
      case String.to_charlist(string) do
        [] ->
          false

        chars ->
          Enum.all?(chars, fn cp -> cp == 0x1230B or cp == 0x12079 or cp == ?\s end)
      end
    end
  end
end
