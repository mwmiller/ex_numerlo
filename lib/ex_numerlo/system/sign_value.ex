defmodule ExNumerlo.System.SignValue do
  @moduledoc false

  # All-literal tuples are folded to plain tuples by the parser;
  # otherwise they arrive as {:{}, meta, [value, glyph]} AST.
  defp normalize_mapping({:{}, _meta, [value, glyph]}), do: {value, glyph}
  defp normalize_mapping(pair) when is_tuple(pair), do: pair

  defmacro __using__(opts) do
    mapping =
      opts
      |> Keyword.fetch!(:mapping)
      |> Enum.map(&normalize_mapping/1)

    error = Keyword.get(opts, :error, :invalid_numeral)

    value_map = Map.new(mapping, fn {value, cp} -> {cp, value} end)

    quote do
      @behaviour ExNumerlo.System

      @impl ExNumerlo.System
      def encode(n, opts \\ [])

      def encode(n, _opts) when is_integer(n) and n > 0 do
        {:ok, do_encode(n, unquote(Macro.escape(mapping)))}
      end

      def encode(n, _opts) when is_integer(n), do: {:error, :not_positive}

      defp do_encode(0, _mapping), do: ""

      defp do_encode(n, [{value, cp} | rest]) do
        count = div(n, value)
        remainder = rem(n, value)
        # Sign-value systems repeat the glyph for each multiple of a power of ten.
        String.duplicate(<<cp::utf8>>, count) <> do_encode(remainder, rest)
      end

      @impl ExNumerlo.System
      def decode(string, _opts \\ []) do
        string
        |> String.to_charlist()
        |> Enum.reduce_while({:ok, 0}, fn cp, {:ok, acc} ->
          case unquote(Macro.escape(value_map))[cp] do
            value when is_integer(value) ->
              {:cont, {:ok, acc + value}}

            nil ->
              {:halt, {:error, unquote(error)}}
          end
        end)
      end

      @impl ExNumerlo.System
      def detect?(string) do
        case String.to_charlist(string) do
          [] ->
            false

          chars ->
            Enum.all?(chars, fn cp ->
              Map.has_key?(unquote(Macro.escape(value_map)), cp)
            end)
        end
      end
    end
  end
end
