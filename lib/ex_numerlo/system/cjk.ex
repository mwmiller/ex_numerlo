defmodule ExNumerlo.System.CJK do
  @moduledoc false

  defmodule Han do
    @moduledoc false
    @behaviour ExNumerlo.System

    @digits %{
      0 => "零",
      1 => "一",
      2 => "二",
      3 => "三",
      4 => "四",
      5 => "五",
      6 => "六",
      7 => "七",
      8 => "八",
      9 => "九"
    }

    @units ["", "十", "百", "千"]
    @sections ["", "万", "亿", "兆"]

    @impl ExNumerlo.System
    def encode(n, opts \\ [])
    def encode(0, _opts), do: {:ok, "零"}
    def encode(n, _opts) when n < 0, do: {:ok, "负" <> do_encode(abs(n))}
    def encode(n, _opts), do: {:ok, do_encode(n)}

    defp do_encode(n) do
      n
      |> Integer.digits(10_000)
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.map(fn {group, idx} ->
        unit = Enum.at(@sections, idx)
        {encode_group(group), unit}
      end)
      |> Enum.reverse()
      |> format_sections()
    end

    defp encode_group(0), do: ""

    defp encode_group(n) do
      digits = Integer.digits(n)
      len = length(digits)

      digits
      |> Enum.with_index()
      |> Enum.reduce({"", false}, &do_encode_group(&1, &2, len))
      |> elem(0)
    end

    defp do_encode_group({0, _i}, {acc, _zero_pending}, _len), do: {acc, true}

    defp do_encode_group({d, i}, {acc, zero_pending}, len) do
      pos = len - i - 1
      unit = Enum.at(@units, pos)
      prefix = if zero_pending, do: "零", else: ""
      char = @digits[d]
      {acc <> prefix <> char <> unit, false}
    end

    defp format_sections(sections) do
      # Sections are groups of 10,000 (myriads). Internal zero groups
      # require a '零' placeholder, but multiple consecutive zero groups
      # only get one placeholder.
      sections
      |> Enum.reduce({"", false}, &do_format_sections/2)
      |> elem(0)
      |> strip_leading_one_ten()
    end

    defp do_format_sections({"", _unit}, {acc, _zero_needed}), do: {acc, true}

    defp do_format_sections({encoded, unit}, {acc, zero_needed}) do
      prefix = if zero_needed and acc != "", do: "零", else: ""
      {acc <> prefix <> encoded <> unit, false}
    end

    defp strip_leading_one_ten("一十" <> rest), do: "十" <> rest
    defp strip_leading_one_ten(s), do: s

    @impl ExNumerlo.System
    def decode(string, _opts \\ []) do
      # Decoding Han hybrid numerals is non-trivial due to the multiplicative
      # structure. We currently support simple constants and negative numbers.
      chars = String.to_charlist(string)

      case chars do
        [?负 | rest] ->
          with {:ok, val} <- do_decode(rest), do: {:ok, -val}

        rest ->
          do_decode(rest)
      end
    end

    defp do_decode([]), do: {:error, :invalid_han_numeral}
    defp do_decode([?零]), do: {:ok, 0}
    defp do_decode([?〇]), do: {:ok, 0}

    defp do_decode(_chars) do
      # Full myriad-based hybrid decoder remains to be implemented.
      {:error, :not_implemented}
    end

    @impl ExNumerlo.System
    def detect?(string) do
      # Detection for hybrid Han is hard without a full parser.
      # We'll check if it contains any Han digits or units.
      chars = String.to_charlist(string)

      not_empty?(chars) and
        Enum.all?(chars, fn cp ->
          Map.values(@digits)
          |> Enum.map(&String.to_charlist/1)
          |> Enum.map(&hd/1)
          |> Enum.member?(cp) or
            Enum.member?([?十, ?百, ?千, ?万, ?亿, ?负, ?〇], cp)
        end)
    end

    defp not_empty?([]), do: false
    defp not_empty?(_), do: true
  end

  defmodule HanPositional do
    @moduledoc false
    @behaviour ExNumerlo.System

    @mapping %{
      # 〇
      0 => 0x3007,
      # 一
      1 => 0x4E00,
      # 二
      2 => 0x4E8C,
      # 三
      3 => 0x4E09,
      # 四
      4 => 0x56DB,
      # 五
      5 => 0x4E94,
      # 六
      6 => 0x516D,
      # 七
      7 => 0x4E03,
      # 八
      8 => 0x516B,
      # 九
      9 => 0x4E5D
    }

    @impl ExNumerlo.System
    def encode(n, opts) when is_integer(n) do
      separator = Keyword.get(opts, :separator)

      encoded =
        n
        |> abs()
        |> Integer.digits(10)
        |> Enum.map(fn d -> @mapping[d] end)
        |> apply_separator(separator)
        |> List.to_string()
        |> prepend_sign(n)

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
          {:ok, d} -> {:cont, {:ok, acc * 10 + d}}
          _ -> {:halt, {:error, :invalid_digit}}
        end
      end)
      |> apply_sign(chars)
    end

    defp find_digit(cp) do
      @mapping
      |> Enum.find(fn {_, v} -> v == cp end)
      |> case do
        {d, _} -> {:ok, d}
        nil -> {:error, :invalid_digit}
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
      case String.to_charlist(string) do
        [] ->
          false

        chars ->
          Enum.all?(chars, fn cp -> match?({:ok, _}, find_digit(cp)) end)
      end
    end
  end

  defmodule Suzhou do
    @moduledoc false
    @behaviour ExNumerlo.System

    @impl ExNumerlo.System
    def encode(n, opts \\ []) when is_integer(n) do
      separator = Keyword.get(opts, :separator)

      encoded =
        n
        |> abs()
        |> Integer.digits(10)
        |> Enum.map(fn
          0 -> 0x3007
          d -> 0x3021 + d - 1
        end)
        |> apply_separator(separator)
        |> List.to_string()
        |> prepend_sign(n)

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
        case cp do
          0x3007 -> {:cont, {:ok, acc * 10}}
          cp when cp >= 0x3021 and cp <= 0x3029 -> {:cont, {:ok, acc * 10 + (cp - 0x3021 + 1)}}
          _ -> {:halt, {:error, :invalid_digit}}
        end
      end)
      |> apply_sign(chars)
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
      case String.to_charlist(string) do
        [] ->
          false

        chars ->
          Enum.all?(chars, fn cp ->
            cp == 0x3007 or (cp >= 0x3021 and cp <= 0x3029)
          end)
      end
    end
  end

  defmodule Rod do
    @moduledoc false
    @behaviour ExNumerlo.System

    # Counting rod numerals are positional base-10, but they alternate between
    # vertical and horizontal forms for even/odd powers of ten to help
    # the reader distinguish between adjacent digits without a zero glyph.
    # We use '〇' for zero in modern representations.

    @impl ExNumerlo.System
    def encode(n, _opts \\ []) when is_integer(n) do
      digits = n |> abs() |> Integer.digits(10)
      len = length(digits)

      encoded =
        digits
        |> Enum.with_index()
        |> Enum.map_join(&encode_rod_digit(&1, len))

      {:ok, if(n < 0, do: "-" <> encoded, else: encoded)}
    end

    defp encode_rod_digit({0, _i}, _len), do: "〇"

    defp encode_rod_digit({d, i}, len) do
      pos = len - i - 1
      base = if rem(pos, 2) == 0, do: 0x1D360, else: 0x1D369
      List.to_string([base + d - 1])
    end

    @impl ExNumerlo.System
    def decode(string, _opts \\ []) do
      chars = String.to_charlist(string)

      chars
      |> strip_sign()
      |> Enum.reduce_while({:ok, 0}, fn cp, {:ok, acc} ->
        case cp do
          0x3007 ->
            {:cont, {:ok, acc * 10}}

          cp when cp >= 0x1D360 and cp <= 0x1D368 ->
            {:cont, {:ok, acc * 10 + (cp - 0x1D360 + 1)}}

          cp when cp >= 0x1D369 and cp <= 0x1D371 ->
            {:cont, {:ok, acc * 10 + (cp - 0x1D369 + 1)}}

          _ ->
            {:halt, {:error, :invalid_digit}}
        end
      end)
      |> apply_sign(chars)
    end

    defp strip_sign([?+ | rest]), do: rest
    defp strip_sign([?- | rest]), do: rest
    defp strip_sign(rest), do: rest

    defp apply_sign({:ok, val}, [?- | _]), do: {:ok, -val}
    defp apply_sign(res, _chars), do: res

    @impl ExNumerlo.System
    def detect?(string) do
      case String.to_charlist(string) do
        [] ->
          false

        chars ->
          Enum.all?(chars, fn cp ->
            cp == 0x3007 or (cp >= 0x1D360 and cp <= 0x1D371)
          end)
      end
    end
  end
end
