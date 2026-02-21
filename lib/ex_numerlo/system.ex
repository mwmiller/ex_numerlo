defmodule ExNumerlo.System do
  @moduledoc """
  Defines the behaviour for all numeral systems supported by ExNumerlo.

  Each system must implement functions for encoding integers, decoding strings,
  and detecting if a string contains numerals belonging to that system.
  """

  @callback encode(integer(), keyword()) :: {:ok, String.t()} | {:error, term()}
  @callback decode(String.t(), keyword()) :: {:ok, integer()} | {:error, term()}
  @callback detect?(String.t()) :: boolean()
end
