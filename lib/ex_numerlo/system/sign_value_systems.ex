defmodule ExNumerlo.System.ArabicAbjad do
  @moduledoc false
  use ExNumerlo.System.SignValue,
    error: :invalid_abjad_numeral,
    mapping: [
      {1000, 0x063A},
      {900, 0x0638},
      {800, 0x0636},
      {700, 0x0630},
      {600, 0x062E},
      {500, 0x062B},
      {400, 0x062A},
      {300, 0x0634},
      {200, 0x0631},
      {100, 0x0642},
      {90, 0x0635},
      {80, 0x0641},
      {70, 0x0639},
      {60, 0x0633},
      {50, 0x0646},
      {40, 0x0645},
      {30, 0x0644},
      {20, 0x0643},
      {10, 0x064A},
      {9, 0x0637},
      {8, 0x062D},
      {7, 0x0632},
      {6, 0x0648},
      {5, 0x0647},
      {4, 0x062F},
      {3, 0x062C},
      {2, 0x0628},
      {1, 0x0627}
    ]
end

defmodule ExNumerlo.System.TamilTraditional do
  @moduledoc false
  use ExNumerlo.System.SignValue,
    error: :invalid_tamil_traditional_numeral,
    mapping: [
      {1000, 0x0BF2},
      {100, 0x0BF1},
      {10, 0x0BF0},
      {9, 0x0BEF},
      {8, 0x0BEE},
      {7, 0x0BED},
      {6, 0x0BEC},
      {5, 0x0BEB},
      {4, 0x0BEA},
      {3, 0x0BE9},
      {2, 0x0BE8},
      {1, 0x0BE7}
    ]
end

defmodule ExNumerlo.System.SinhalaArchaic do
  @moduledoc false
  use ExNumerlo.System.SignValue,
    error: :invalid_sinhala_archaic_numeral,
    mapping: [
      {1000, 0x111F4},
      {100, 0x111F3},
      {90, 0x111F2},
      {80, 0x111F1},
      {70, 0x111F0},
      {60, 0x111EF},
      {50, 0x111EE},
      {40, 0x111ED},
      {30, 0x111EC},
      {20, 0x111EB},
      {10, 0x111EA},
      {9, 0x111E9},
      {8, 0x111E8},
      {7, 0x111E7},
      {6, 0x111E6},
      {5, 0x111E5},
      {4, 0x111E4},
      {3, 0x111E3},
      {2, 0x111E2},
      {1, 0x111E1}
    ]
end

defmodule ExNumerlo.System.Kharosthi do
  @moduledoc false
  use ExNumerlo.System.SignValue,
    error: :invalid_kharosthi_numeral,
    mapping: [
      {1000, 0x10A47},
      {100, 0x10A46},
      {20, 0x10A45},
      {10, 0x10A44},
      {4, 0x10A43},
      {3, 0x10A42},
      {2, 0x10A41},
      {1, 0x10A40}
    ]
end

defmodule ExNumerlo.System.Rumi do
  @moduledoc false
  use ExNumerlo.System.SignValue,
    error: :invalid_rumi_numeral,
    mapping: [
      {900, 0x10E7A},
      {800, 0x10E79},
      {700, 0x10E78},
      {600, 0x10E77},
      {500, 0x10E76},
      {400, 0x10E75},
      {300, 0x10E74},
      {200, 0x10E73},
      {100, 0x10E72},
      {90, 0x10E71},
      {80, 0x10E70},
      {70, 0x10E6F},
      {60, 0x10E6E},
      {50, 0x10E6D},
      {40, 0x10E6C},
      {30, 0x10E6B},
      {20, 0x10E6A},
      {10, 0x10E69},
      {9, 0x10E68},
      {8, 0x10E67},
      {7, 0x10E66},
      {6, 0x10E65},
      {5, 0x10E64},
      {4, 0x10E63},
      {3, 0x10E62},
      {2, 0x10E61},
      {1, 0x10E60}
    ]
end
