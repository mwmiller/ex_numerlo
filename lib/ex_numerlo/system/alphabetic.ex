defmodule ExNumerlo.System.Alphabetic do
  @moduledoc false

  # Literal tuples with non-literal elements (e.g. a list of glyphs)
  # arrive as {:{}, meta, [value, glyphs, prefix]} AST. All-literal tuples
  # are folded to plain tuples by the parser, so we accept both forms.
  defp normalize_tier({:{}, _meta, [value, glyphs, prefix]}), do: {value, glyphs, prefix}
  defp normalize_tier(tier) when is_tuple(tier), do: tier

  defmacro __using__(opts) do
    tiers =
      opts
      |> Keyword.fetch!(:tiers)
      |> Enum.map(&normalize_tier/1)

    error = Keyword.get(opts, :error, :invalid_numeral)

    max =
      Enum.reduce(tiers, 0, fn {value, glyphs, _prefix}, acc ->
        acc + value * length(glyphs)
      end)

    prefixed_tier = Enum.find(tiers, fn {_v, _g, prefix} -> not is_nil(prefix) end)
    normal_tiers = Enum.reject(tiers, fn {_v, _g, prefix} -> not is_nil(prefix) end)

    normal_map =
      Enum.reduce(normal_tiers, %{}, fn {value, glyphs, _prefix}, acc ->
        glyphs
        |> Enum.with_index(1)
        |> Enum.reduce(acc, fn {cp, digit}, acc -> Map.put(acc, cp, {value, digit}) end)
      end)

    all_cps =
      Enum.reduce(tiers, MapSet.new(), fn {_value, glyphs, prefix}, acc ->
        acc = Enum.reduce(glyphs, acc, &MapSet.put(&2, &1))
        if prefix, do: MapSet.put(acc, prefix), else: acc
      end)

    detect_map = Map.new(all_cps, &{&1, true})

    prefix_clauses =
      case prefixed_tier do
        {value, glyphs, prefix} ->
          prefixed_map =
            glyphs
            |> Enum.with_index(1)
            |> Map.new(fn {cp, digit} -> {cp, digit} end)

          quote do
            defp do_decode([cp | rest], :normal, acc) when cp == unquote(prefix) do
              do_decode(rest, :thousands, acc)
            end

            defp do_decode([cp | rest], :thousands, acc) do
              case unquote(Macro.escape(prefixed_map))[cp] do
                digit when is_integer(digit) ->
                  do_decode(rest, :normal, acc + digit * unquote(value))

                nil ->
                  {:error, unquote(error)}
              end
            end
          end

        nil ->
          quote(do: :ok)
      end

    quote do
      @behaviour ExNumerlo.System

      @impl ExNumerlo.System
      def encode(n, opts \\ [])

      def encode(n, _opts) when is_integer(n) and n > 0 and n <= unquote(max) do
        {:ok, do_encode(n, unquote(Macro.escape(tiers)))}
      end

      def encode(n, _opts) when is_integer(n) and n > 0, do: {:error, :out_of_range}
      def encode(n, _opts) when is_integer(n), do: {:error, :not_positive}

      defp do_encode(0, _tiers), do: ""
      defp do_encode(_n, []), do: ""

      defp do_encode(n, [{value, glyphs, prefix} | rest]) do
        digit = div(n, value)
        remainder = rem(n, value)

        part =
          if digit > 0 do
            prefix_part = if prefix, do: <<prefix::utf8>>, else: ""
            prefix_part <> <<Enum.at(glyphs, digit - 1)::utf8>>
          else
            ""
          end

        part <> do_encode(remainder, rest)
      end

      @impl ExNumerlo.System
      def decode(string, _opts \\ []) do
        string
        |> String.to_charlist()
        |> do_decode(:normal, 0)
      end

      defp do_decode([], _mode, acc), do: {:ok, acc}

      unquote(prefix_clauses)

      defp do_decode([cp | rest], :normal, acc) do
        case unquote(Macro.escape(normal_map))[cp] do
          {value, digit} -> do_decode(rest, :normal, acc + value * digit)
          nil -> {:error, unquote(error)}
        end
      end

      @impl ExNumerlo.System
      def detect?(string) do
        case String.to_charlist(string) do
          [] ->
            false

          chars ->
            Enum.all?(chars, fn cp ->
              Map.has_key?(unquote(Macro.escape(detect_map)), cp)
            end)
        end
      end
    end
  end
end
