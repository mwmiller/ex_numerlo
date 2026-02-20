defmodule ExNumerlo.System.Arabic do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x0030
end

defmodule ExNumerlo.System.ArabicIndic do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x0660
end

defmodule ExNumerlo.System.ExtendedArabicIndic do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x06F0
end

defmodule ExNumerlo.System.Devanagari do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x0966
end

defmodule ExNumerlo.System.Bengali do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x09E6
end

defmodule ExNumerlo.System.Gurmukhi do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x0A66
end

defmodule ExNumerlo.System.Gujarati do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x0AE6
end

defmodule ExNumerlo.System.Oriya do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x0B66
end

defmodule ExNumerlo.System.Tamil do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x0BE6
end

defmodule ExNumerlo.System.Telugu do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x0C66
end

defmodule ExNumerlo.System.Kannada do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x0CE6
end

defmodule ExNumerlo.System.Malayalam do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x0D66
end

defmodule ExNumerlo.System.Thai do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x0E50
end

defmodule ExNumerlo.System.Lao do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x0ED0
end

defmodule ExNumerlo.System.Tibetan do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x0F20
end

defmodule ExNumerlo.System.Burmese do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x1040
end

defmodule ExNumerlo.System.Khmer do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x17E0
end

defmodule ExNumerlo.System.Mongolian do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x1810
end

defmodule ExNumerlo.System.Fullwidth do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0xFF10
end

defmodule ExNumerlo.System.MathBold do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x1D7CE
end

defmodule ExNumerlo.System.MathDoubleStruck do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x1D7D8
end

defmodule ExNumerlo.System.MathSans do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x1D7E2
end

defmodule ExNumerlo.System.MathSansBold do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x1D7EC
end

defmodule ExNumerlo.System.MathMonospace do
  @moduledoc false
  use ExNumerlo.System.Positional, base: 0x1D7F6
end
