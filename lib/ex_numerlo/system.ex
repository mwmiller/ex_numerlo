defmodule ExNumerlo.System do
  @moduledoc """
  A behaviour for numeral systems.
  """

  @callback encode(integer(), keyword()) :: {:ok, String.t()} | {:error, term()}
  @callback decode(String.t(), keyword()) :: {:ok, integer()} | {:error, term()}
  @callback detect?(String.t()) :: boolean()
end
