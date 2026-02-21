defmodule ExNumerlo do
  @moduledoc """
  ExNumerlo provides a unified interface for rendering and parsing integers using over 50 different Unicode numeral systems.

  It supports modern positional systems, historical additive and hybrid systems, and specialized mathematical representations.

  ## Core Features

  - **Unified API:** Use `convert/2` for encoding, decoding, and cross-system conversion.
  - **Auto-Detection:** Automatically identify the source numeral system when decoding strings.
  - **Broad Support:** Coverage for dozens of scripts including CJK, Indic, African, and historical systems.
  - **Formatting:** Support for custom separators (e.g., thousands separators) in positional systems.

  ## Supported Systems

  ### Modern Positional (Base-10)
  `:arabic`, `:arabic_indic`, `:extended_arabic_indic`, `:devanagari`, `:bengali`, `:gurmukhi`,
  `:gujarati`, `:oriya`, `:tamil`, `:telugu`, `:kannada`, `:malayalam`, `:thai`, `:lao`,
  `:tibetan`, `:burmese`, `:khmer`, `:mongolian`, `:adlam`, `:balinese`, `:chakma`, `:cham`,
  `:gunjala_gondi`, `:javanese`, `:kayah_li`, `:lepcha`, `:limbu`, `:masaram_gondi`,
  `:meetei_mayek`, `:modi`, `:mro`, `:n_ko`, `:new_tai_lue`, `:nyiakeng_puachue_hmong`,
  `:ol_chiki`, `:osmanya`, `:pahawh_hmong`, `:saurashtra`, `:sharada`, `:sora_sompeng`,
  `:sundanese`, `:tai_tham_hora`, `:tai_tham_tham`, `:takri`, `:tangsa`, `:tirhuta`,
  `:toto`, `:vai`, `:wancho`, `:warang_citi`, `:nag_mundari`, `:fullwidth`

  ### Historical and Specialized
  - **Additive:** `:roman` (1-3999), `:aegean`, `:attic`, `:brahmi`
  - **Hybrid:** `:ethiopic`, `:han` (Chinese/Japanese myriad-based)
  - **Positional (Non-Base-10):** `:mayan` (Base-20), `:kaktovik` (Base-20), `:cuneiform` (Base-60), `:duodecimal` (Base-12)
  - **Specialized:** `:han_positional`, `:suzhou`, `:rod`, `:math_bold`, `:math_double_struck`, `:math_monospace`, `:math_sans`, `:math_sans_bold`

  ## Usage Examples

  ### Encoding
      ExNumerlo.convert(123, to: :devanagari)
      # {:ok, "१२३"}

      ExNumerlo.convert(2026, to: :roman)
      # {:ok, "MMXXVI"}

  ### Decoding with Auto-Detection
      ExNumerlo.convert("१२३", to: :integer)
      # {:ok, 123}

      ExNumerlo.convert("MMXXVI", to: :integer)
      # {:ok, 2026}

  ### Formatting with Separators
      ExNumerlo.convert(1234567, to: :arabic, separator: ",")
      # {:ok, "1,234,567"}

      ExNumerlo.convert("1,234,567", to: :integer, separator: ",")
      # {:ok, 1234567}
  """

  alias ExNumerlo.System

  @typedoc "Supported numeral systems."
  @type system ::
          :arabic
          | :arabic_indic
          | :extended_arabic_indic
          | :devanagari
          | :bengali
          | :gurmukhi
          | :gujarati
          | :oriya
          | :tamil
          | :telugu
          | :kannada
          | :malayalam
          | :thai
          | :lao
          | :tibetan
          | :burmese
          | :khmer
          | :mongolian
          | :limbu
          | :new_tai_lue
          | :tai_tham_hora
          | :tai_tham_tham
          | :balinese
          | :sundanese
          | :lepcha
          | :ol_chiki
          | :vai
          | :saurashtra
          | :kayah_li
          | :javanese
          | :cham
          | :meetei_mayek
          | :osmanya
          | :brahmi
          | :sora_sompeng
          | :chakma
          | :sharada
          | :tirhuta
          | :modi
          | :takri
          | :warang_citi
          | :gunjala_gondi
          | :masaram_gondi
          | :kaktovik
          | :mro
          | :tangsa
          | :pahawh_hmong
          | :nyiakeng_puachue_hmong
          | :wancho
          | :toto
          | :nag_mundari
          | :adlam
          | :n_ko
          | :han
          | :han_positional
          | :suzhou
          | :rod
          | :fullwidth
          | :math_monospace
          | :math_bold
          | :math_double_struck
          | :math_sans
          | :math_sans_bold
          | :roman
          | :aegean
          | :attic
          | :mayan
          | :ethiopic
          | :cuneiform
          | :duodecimal

  @systems_metadata %{
    # Additive and Hybrid systems
    aegean: %{
      description:
        "Aegean numerals used by Minoan and Mycenaean civilizations (Linear A/B). Uses distinct glyphs for powers of 10 from 1 to 10,000.",
      base: 10,
      type: :additive,
      range: :positive,
      example: "𐄫𐄢𐄙𐄐𐄇 (11,111)"
    },
    attic: %{
      description:
        "Ancient Greek acrophonic system where symbols derive from the first letter of the number's name (e.g., Δ for δέκα/10).",
      base: 10,
      type: :additive,
      range: :positive,
      example: "ΔΔ𐅃ΙΙ (27)"
    },
    mayan: %{
      description:
        "Vigesimal (base-20) positional system used by the Maya civilization. Uses a shell for zero, dots for 1, and bars for 5.",
      base: 20,
      type: :positional,
      range: :non_negative,
      example: "𝋡𝋠 (20)"
    },
    ethiopic: %{
      description:
        "Ge'ez hierarchical additive-multiplicative system using segments of 100. Used in Ethiopia and Eritrea.",
      base: 10,
      type: :hybrid,
      range: :positive,
      example: "፳፫፻፵፭ (2345)"
    },
    cuneiform: %{
      description:
        "Babylonian sexagesimal (base-60) positional system using wedges. Values within each digit are additive.",
      base: 60,
      type: :positional,
      range: :non_negative,
      example: "𒁹  𒌋𒌋𒁹𒁹𒁹 (83)"
    },
    roman: %{
      description:
        "Standard Roman numerals using additive/subtractive notation. Limited to the range 1-3999 in standard Unicode representation.",
      base: 10,
      type: :additive,
      range: 1..3999,
      example: "MMXXVI (2026)"
    },
    # Specialized
    duodecimal: %{
      description:
        "Base-12 system using Pitman's notation (↊ for 10, ↋ for 11). Often preferred by dozenalists for its divisibility.",
      base: 12,
      type: :positional,
      range: :all,
      example: "↊↋ (131)"
    },
    fullwidth: %{
      description:
        "Fixed-width (monospaced) forms of Arabic numerals used in CJK (Chinese, Japanese, Korean) contexts for visual alignment.",
      base: 10,
      type: :positional,
      range: :all,
      example: "１２３ (123)"
    },
    # Math
    math_bold: %{
      description:
        "Mathematical bold serif digits. Used in mathematical notation to distinguish different types of variables.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𝟏𝟐𝟑 (123)"
    },
    math_double_struck: %{
      description:
        "Mathematical blackboard bold digits. Commonly used to represent sets like integers (ℤ) or naturals (ℕ).",
      base: 10,
      type: :positional,
      range: :all,
      example: "𝟙𝟚𝟛 (123)"
    },
    math_monospace: %{
      description:
        "Mathematical fixed-width digits used in specialized mathematical and technical contexts.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𝟷𝟸𝟹 (123)"
    },
    math_sans: %{
      description:
        "Mathematical sans-serif digits used for clean representation in mathematical expressions.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𝟣𝟤𝟥 (123)"
    },
    math_sans_bold: %{
      description:
        "Mathematical bold sans-serif digits used for emphasis in mathematical notation.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𝟭𝟮𝟯 (123)"
    },
    # Modern Positional
    arabic: %{
      description:
        "Standard Western Arabic numerals (0-9). The most widely used numeral system in the world today.",
      base: 10,
      type: :positional,
      range: :all,
      example: "123 (123)"
    },
    arabic_indic: %{
      description: "Standard Arabic-Indic numerals used in most of the Arab world.",
      base: 10,
      type: :positional,
      range: :all,
      example: "١٢٣ (123)"
    },
    extended_arabic_indic: %{
      description:
        "Eastern Arabic-Indic numerals used primarily for Persian and Urdu. Differs from Arabic-Indic for digits 4, 5, and 6.",
      base: 10,
      type: :positional,
      range: :all,
      example: "۱۲۳ (123)"
    },
    devanagari: %{
      description:
        "Numerals used with the Devanagari script, common in India for Hindi, Marathi, and Sanskrit.",
      base: 10,
      type: :positional,
      range: :all,
      example: "१२३ (123)"
    },
    bengali: %{
      description:
        "Bengali-Assamese numerals used in Bangladesh and the Indian states of West Bengal and Assam.",
      base: 10,
      type: :positional,
      range: :all,
      example: "১২৩ (123)"
    },
    gurmukhi: %{
      description: "Gurmukhi script numerals, used primarily for the Punjabi language in India.",
      base: 10,
      type: :positional,
      range: :all,
      example: "੧੨੩ (123)"
    },
    gujarati: %{
      description: "Gujarati script numerals, used for the Gujarati language in India.",
      base: 10,
      type: :positional,
      range: :all,
      example: "૧૨૩ (123)"
    },
    oriya: %{
      description: "Oriya (Odia) script numerals, used for the Odia language in India.",
      base: 10,
      type: :positional,
      range: :all,
      example: "୧୨୩ (123)"
    },
    tamil: %{
      description: "Tamil script numerals, used for the Tamil language in India and Sri Lanka.",
      base: 10,
      type: :positional,
      range: :all,
      example: "௧௨௩ (123)"
    },
    telugu: %{
      description: "Telugu script numerals, used for the Telugu language in India.",
      base: 10,
      type: :positional,
      range: :all,
      example: "౧౨౩ (123)"
    },
    kannada: %{
      description: "Kannada script numerals, used for the Kannada language in India.",
      base: 10,
      type: :positional,
      range: :all,
      example: "೧೨೩ (123)"
    },
    malayalam: %{
      description: "Malayalam script numerals, used for the Malayalam language in India.",
      base: 10,
      type: :positional,
      range: :all,
      example: "൧൨൩ (123)"
    },
    thai: %{
      description: "Thai script numerals, used alongside Western Arabic numerals in Thailand.",
      base: 10,
      type: :positional,
      range: :all,
      example: "๑๒๓ (123)"
    },
    lao: %{
      description: "Lao script numerals, used for the Lao language in Laos.",
      base: 10,
      type: :positional,
      range: :all,
      example: "໑໒໓ (123)"
    },
    tibetan: %{
      description: "Tibetan script numerals, used in Tibet and surrounding regions.",
      base: 10,
      type: :positional,
      range: :all,
      example: "༡༢༣ (123)"
    },
    burmese: %{
      description: "Burmese script numerals, used for the Burmese language in Myanmar.",
      base: 10,
      type: :positional,
      range: :all,
      example: "၁၂၃ (123)"
    },
    khmer: %{
      description: "Khmer script numerals, used for the Khmer language in Cambodia.",
      base: 10,
      type: :positional,
      range: :all,
      example: "១២៣ (123)"
    },
    mongolian: %{
      description:
        "Traditional Mongolian script numerals, used in Inner Mongolia (China) and Mongolia.",
      base: 10,
      type: :positional,
      range: :all,
      example: "᠑᠒᠓ (123)"
    },
    limbu: %{
      description: "Limbu script numerals, used for the Limbu language in Nepal and India.",
      base: 10,
      type: :positional,
      range: :all,
      example: "ᥧᥨᥩ (123)"
    },
    new_tai_lue: %{
      description:
        "New Tai Lue script numerals, used for the Tai Lue language in China and Southeast Asia.",
      base: 10,
      type: :positional,
      range: :all,
      example: "᧑᧒᧓ (123)"
    },
    tai_tham_hora: %{
      description:
        "Tai Tham script numerals (Hora style), used for secular purposes in Northern Thailand and Laos.",
      base: 10,
      type: :positional,
      range: :all,
      example: "᪑᪒᪓ (123)"
    },
    tai_tham_tham: %{
      description:
        "Tai Tham script numerals (Tham style), used for religious purposes in Northern Thailand and Laos.",
      base: 10,
      type: :positional,
      range: :all,
      example: "᪡᪢᪣ (123)"
    },
    balinese: %{
      description: "Balinese script numerals, used for the Balinese language in Indonesia.",
      base: 10,
      type: :positional,
      range: :all,
      example: "᭑᭒᭓ (123)"
    },
    sundanese: %{
      description: "Sundanese script numerals, used for the Sundanese language in Indonesia.",
      base: 10,
      type: :positional,
      range: :all,
      example: "᮱᮲᮳ (123)"
    },
    lepcha: %{
      description:
        "Lepcha script numerals, used for the Lepcha language in Sikkim and Darjeeling.",
      base: 10,
      type: :positional,
      range: :all,
      example: "᱁᱂᱃ (123)"
    },
    ol_chiki: %{
      description:
        "Ol Chiki script numerals, used for the Santali language in India and Bangladesh.",
      base: 10,
      type: :positional,
      range: :all,
      example: "᱑᱒᱓ (123)"
    },
    vai: %{
      description: "Vai script numerals, a syllabic script used for the Vai language in Liberia.",
      base: 10,
      type: :positional,
      range: :all,
      example: "꘡꘢꘣ (123)"
    },
    saurashtra: %{
      description:
        "Saurashtra script numerals, used for the Saurashtra language in Southern India.",
      base: 10,
      type: :positional,
      range: :all,
      example: "꣑꣒꣓ (123)"
    },
    kayah_li: %{
      description: "Kayah Li script numerals, used for the Kayah Li language in Myanmar.",
      base: 10,
      type: :positional,
      range: :all,
      example: "꤁꤂꤃ (123)"
    },
    javanese: %{
      description: "Javanese script numerals, used for the Javanese language in Indonesia.",
      base: 10,
      type: :positional,
      range: :all,
      example: "꧑꧒꧓ (123)"
    },
    cham: %{
      description: "Cham script numerals, used for the Cham language in Vietnam and Cambodia.",
      base: 10,
      type: :positional,
      range: :all,
      example: "꫑꫒꫓ (123)"
    },
    meetei_mayek: %{
      description:
        "Meetei Mayek script numerals, used for the Meiteilon (Manipuri) language in India.",
      base: 10,
      type: :positional,
      range: :all,
      example: "꯱꯲꯳ (123)"
    },
    osmanya: %{
      description:
        "Osmanya script numerals, an alphabetic script used for the Somali language in Somalia.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𐒡𐒢𐒣 (123)"
    },
    brahmi: %{
      description:
        "Ancient Brahmi script decimal digits, the ancestor of most modern Indian and Southeast Asian numeral systems.",
      base: 10,
      type: :positional,
      range: :positive,
      example: "𑁧𑁨𑁩 (123)"
    },
    sora_sompeng: %{
      description: "Sora Sompeng script numerals, used for the Sora language in India.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𑃱𑃲𑃳 (123)"
    },
    chakma: %{
      description:
        "Chakma script numerals, used for the Chakma language in Bangladesh and India.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𑄷𑄸𑄹 (123)"
    },
    sharada: %{
      description: "Sharada script numerals, an ancient script used in Kashmir.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𑇑𑇒𑇓 (123)"
    },
    tirhuta: %{
      description: "Tirhuta script numerals, used for the Maithili language in India and Nepal.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𑓑𑓒𑓓 (123)"
    },
    modi: %{
      description:
        "Modi script numerals, historically used to write the Marathi language in India.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𑙑𑙒𑙓 (123)"
    },
    takri: %{
      description: "Takri script numerals, used for various languages in the Western Himalayas.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𑛁𑛂𑛃 (123)"
    },
    warang_citi: %{
      description: "Warang Citi script numerals, used for the Ho language in India.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𑣡𑣢𑣣 (123)"
    },
    gunjala_gondi: %{
      description: "Gunjala Gondi script numerals, used for the Gondi language in India.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𑶡𑶢𑶣 (123)"
    },
    masaram_gondi: %{
      description:
        "Masaram Gondi script numerals, another script used for the Gondi language in India.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𑵑𑵒𑵓 (123)"
    },
    kaktovik: %{
      description:
        "Kaktovik Inupiaq numerals, a base-20 (vigesimal) system designed by Alaskan Iñupiat to represent their language's oral counting.",
      base: 20,
      type: :positional,
      range: :non_negative,
      example: "𝋆𝋀 (120)"
    },
    mro: %{
      description: "Mro script numerals, used for the Mro language in Bangladesh and Myanmar.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𖩡𖩢𖩣 (123)"
    },
    tangsa: %{
      description: "Tangsa script numerals, used for the Tangsa language in India and Myanmar.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𖫁𖫂𖫃 (123)"
    },
    pahawh_hmong: %{
      description:
        "Pahawh Hmong script numerals, used for the Hmong language in Laos and Thailand.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𖭑𖭒𖭓 (123)"
    },
    nyiakeng_puachue_hmong: %{
      description:
        "Nyiakeng Puachue Hmong script numerals, another script used for the Hmong language.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𞅁𞅂𞅃 (123)"
    },
    wancho: %{
      description: "Wancho script numerals, used for the Wancho language in India.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𞋱𞋲𞋳 (123)"
    },
    toto: %{
      description: "Toto script numerals, used for the Toto language in India.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𞊑𞊒𞊓 (123)"
    },
    nag_mundari: %{
      description: "Nag Mundari script numerals, used for the Mundari language in India.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𞓱𞓲𞓳 (123)"
    },
    adlam: %{
      description: "Adlam script numerals, used for the Fulani language in West Africa.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𞥑𞥒𞥓 (123)"
    },
    n_ko: %{
      description: "N'Ko script numerals, used for the Manding languages in West Africa.",
      base: 10,
      type: :positional,
      range: :all,
      example: "߁߂߃ (123)"
    },
    han: %{
      description:
        "Simplified Chinese/Japanese (Han) hybrid numeral system. Multiplicative-additive using units of 10,000.",
      base: 10,
      type: :hybrid,
      range: :all,
      example: "一万二千三百四十五 (12,345)"
    },
    han_positional: %{
      description: "Positional use of Han numerals, common in modern contexts like dates.",
      base: 10,
      type: :positional,
      range: :all,
      example: "二〇二六 (2026)"
    },
    suzhou: %{
      description:
        "Suzhou numerals (huama), a shorthand numeral system once common in Chinese markets.",
      base: 10,
      type: :positional,
      range: :all,
      example: "〡〢〣 (123)"
    },
    rod: %{
      description:
        "Counting rod numerals, an ancient positional system using vertical and horizontal strokes.",
      base: 10,
      type: :positional,
      range: :all,
      example: "𝍠𝍩𝍢 (123)"
    }
  }

  # Priority for auto-detection. Unique/Complex glyphs are checked first
  # to prevent false positives in more generic systems (like standard digits).
  @all_systems [
    # Unique/Complex glyphs take priority
    :aegean,
    :attic,
    :mayan,
    :ethiopic,
    :cuneiform,
    :roman,
    # Specialized digits
    :math_bold,
    :math_double_struck,
    :math_sans,
    :math_sans_bold,
    :math_monospace,
    :fullwidth,
    # Standard script digits
    :thai,
    :lao,
    :tibetan,
    :burmese,
    :khmer,
    :mongolian,
    :limbu,
    :new_tai_lue,
    :tai_tham_hora,
    :tai_tham_tham,
    :balinese,
    :sundanese,
    :lepcha,
    :ol_chiki,
    :vai,
    :saurashtra,
    :kayah_li,
    :javanese,
    :cham,
    :meetei_mayek,
    :osmanya,
    :brahmi,
    :sora_sompeng,
    :chakma,
    :sharada,
    :tirhuta,
    :modi,
    :takri,
    :warang_citi,
    :gunjala_gondi,
    :masaram_gondi,
    :kaktovik,
    :mro,
    :tangsa,
    :pahawh_hmong,
    :nyiakeng_puachue_hmong,
    :wancho,
    :toto,
    :nag_mundari,
    :adlam,
    :n_ko,
    :suzhou,
    :rod,
    :han_positional,
    :han,
    :devanagari,
    :bengali,
    :gurmukhi,
    :gujarati,
    :oriya,
    :tamil,
    :telugu,
    :kannada,
    :malayalam,
    # Generic digits last
    :arabic,
    :arabic_indic,
    :extended_arabic_indic,
    :duodecimal
  ]

  @doc """
  Returns metadata for all supported numeral systems.

  ## Examples
      iex> ExNumerlo.systems()[:roman][:range]
      1..3999

      iex> %{mayan: %{base: base}} = ExNumerlo.systems()
      iex> base
      20
  """
  @spec systems() :: %{system() => map()}
  def systems, do: @systems_metadata

  @doc """
  Converts an input (integer, list of integers, or encoded string) to another numeral system.

  ## Options

    - `:to` - The target system (default: `:arabic`). Use `:integer` to decode to an Elixir integer.
    - `:from` - The source system (default: `:auto`). When set to `:auto`, the library will attempt
      to identify the system based on the characters present in the string.
    - `:separator` - A string to use as a digit group separator (e.g., `,` for thousands).
      Only supported for positional numeral systems.

  ## Returns

    - `{:ok, encoded_string}` for single integer inputs.
    - `{:ok, [encoded_strings]}` for list inputs.
    - `{:ok, integer}` when `to: :integer` is used.
    - `{:error, reason}` if the input is invalid or the conversion is not supported.

  ## Examples

      iex> ExNumerlo.convert(123, to: :devanagari)
      {:ok, "१२३"}

      iex> ExNumerlo.convert(123, to: :thai)
      {:ok, "๑๒๓"}

      iex> ExNumerlo.convert(123, to: :roman)
      {:ok, "CXXIII"}

      iex> ExNumerlo.convert(120, to: :kaktovik)
      {:ok, "𝋆𝋀"}

      iex> ExNumerlo.convert("MMXXVI", to: :integer)
      {:ok, 2026}

      iex> ExNumerlo.convert("𝋆𝋀", to: :integer)
      {:ok, 120}

      iex> ExNumerlo.convert([1, 2], to: :roman)
      {:ok, ["I", "II"]}
  """
  @spec convert(integer() | [integer()] | String.t(), keyword()) ::
          {:ok, String.t() | [String.t()] | integer()} | {:error, term()}
  def convert(input, opts \\ [])

  def convert(numbers, opts) when is_list(numbers) do
    target_system = Keyword.get(opts, :to, :arabic)

    # We use reduce_while here to ensure we stop immediately
    # if any element in the list fails to encode.
    numbers
    |> Enum.reduce_while({:ok, []}, fn n, {:ok, acc} ->
      case convert(n, to: target_system) do
        {:ok, res} -> {:cont, {:ok, [res | acc]}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
    |> case do
      {:ok, list} -> {:ok, Enum.reverse(list)}
      error -> error
    end
  end

  def convert(input, opts) when is_integer(input) do
    target_system = Keyword.get(opts, :to, :arabic)

    case system_module(target_system) do
      nil -> {:error, :unknown_system}
      module -> module.encode(input, opts)
    end
  end

  def convert(input, opts) when is_binary(input) do
    source_system = Keyword.get(opts, :from, :auto)
    target_system = Keyword.get(opts, :to, :arabic)

    with {:ok, value} <- do_decode(input, source_system, opts) do
      case target_system do
        :integer -> {:ok, value}
        _ -> convert(value, to: target_system)
      end
    end
  end

  defp do_decode(string, :auto, opts) do
    # During auto-detection, we check systems in @all_systems order
    # to prioritize more specific systems over generic ones.
    @all_systems
    |> Enum.find(fn sys ->
      case system_module(sys) do
        nil -> false
        module -> module.detect?(string)
      end
    end)
    |> case do
      nil -> {:error, :unknown_system}
      sys -> do_decode(string, sys, opts)
    end
  end

  defp do_decode(string, system, opts) do
    case system_module(system) do
      nil -> {:error, :unknown_system}
      module -> module.decode(string, opts)
    end
  end

  defp system_module(:arabic), do: System.Arabic
  defp system_module(:arabic_indic), do: System.ArabicIndic
  defp system_module(:extended_arabic_indic), do: System.ExtendedArabicIndic
  defp system_module(:devanagari), do: System.Devanagari
  defp system_module(:bengali), do: System.Bengali
  defp system_module(:gurmukhi), do: System.Gurmukhi
  defp system_module(:gujarati), do: System.Gujarati
  defp system_module(:oriya), do: System.Oriya
  defp system_module(:tamil), do: System.Tamil
  defp system_module(:telugu), do: System.Telugu
  defp system_module(:kannada), do: System.Kannada
  defp system_module(:malayalam), do: System.Malayalam
  defp system_module(:thai), do: System.Thai
  defp system_module(:lao), do: System.Lao
  defp system_module(:tibetan), do: System.Tibetan
  defp system_module(:burmese), do: System.Burmese
  defp system_module(:khmer), do: System.Khmer
  defp system_module(:mongolian), do: System.Mongolian
  defp system_module(:limbu), do: System.Limbu
  defp system_module(:new_tai_lue), do: System.NewTaiLue
  defp system_module(:tai_tham_hora), do: System.TaiThamHora
  defp system_module(:tai_tham_tham), do: System.TaiThamTham
  defp system_module(:balinese), do: System.Balinese
  defp system_module(:sundanese), do: System.Sundanese
  defp system_module(:lepcha), do: System.Lepcha
  defp system_module(:ol_chiki), do: System.OlChiki
  defp system_module(:vai), do: System.Vai
  defp system_module(:saurashtra), do: System.Saurashtra
  defp system_module(:kayah_li), do: System.KayahLi
  defp system_module(:javanese), do: System.Javanese
  defp system_module(:cham), do: System.Cham
  defp system_module(:meetei_mayek), do: System.MeeteiMayek
  defp system_module(:osmanya), do: System.Osmanya
  defp system_module(:brahmi), do: System.Brahmi
  defp system_module(:sora_sompeng), do: System.SoraSompeng
  defp system_module(:chakma), do: System.Chakma
  defp system_module(:sharada), do: System.Sharada
  defp system_module(:tirhuta), do: System.Tirhuta
  defp system_module(:modi), do: System.Modi
  defp system_module(:takri), do: System.Takri
  defp system_module(:warang_citi), do: System.WarangCiti
  defp system_module(:gunjala_gondi), do: System.GunjalaGondi
  defp system_module(:masaram_gondi), do: System.MasaramGondi
  defp system_module(:kaktovik), do: System.Kaktovik
  defp system_module(:mro), do: System.Mro
  defp system_module(:tangsa), do: System.Tangsa
  defp system_module(:pahawh_hmong), do: System.PahawhHmong
  defp system_module(:nyiakeng_puachue_hmong), do: System.NyiakengPuachueHmong
  defp system_module(:wancho), do: System.Wancho
  defp system_module(:toto), do: System.Toto
  defp system_module(:nag_mundari), do: System.NagMundari
  defp system_module(:adlam), do: System.Adlam
  defp system_module(:n_ko), do: System.NKo
  defp system_module(:han), do: System.CJK.Han
  defp system_module(:han_positional), do: System.CJK.HanPositional
  defp system_module(:suzhou), do: System.CJK.Suzhou
  defp system_module(:rod), do: System.CJK.Rod
  defp system_module(:fullwidth), do: System.Fullwidth
  defp system_module(:math_bold), do: System.MathBold
  defp system_module(:math_double_struck), do: System.MathDoubleStruck
  defp system_module(:math_sans), do: System.MathSans
  defp system_module(:math_sans_bold), do: System.MathSansBold
  defp system_module(:math_monospace), do: System.MathMonospace
  defp system_module(:roman), do: System.Roman
  defp system_module(:aegean), do: System.Historical.Aegean
  defp system_module(:attic), do: System.Historical.Attic
  defp system_module(:mayan), do: System.Historical.Mayan
  defp system_module(:ethiopic), do: System.Historical.Ethiopic
  defp system_module(:cuneiform), do: System.Historical.Cuneiform
  defp system_module(:duodecimal), do: System.Duodecimal
  defp system_module(_), do: nil
end
