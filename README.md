# ExNumerlo

ExNumerlo is an Elixir library for rendering and parsing integers using various Unicode numeral systems. It supports **88 systems** — from the modern positional scripts of South and Southeast Asia to ancient additive systems like Mayan and Kaktovik, and specialized mathematical and programmer bases.

## Features

- **Unified API:** One function (`ExNumerlo.convert/2`) for all your conversion needs — encoding, decoding, and cross-system conversion.
- **Auto-Detection:** Intelligent source system detection for easy decoding. Pass `from:` explicitly when ambiguity matters.
- **Broad Support:** From Western Arabic to ancient Mayan and Kaktovik Iñupiaq numerals.
- **Formatted Input:** Support for separators (e.g., thousands separators) and `+`/`-` signs in positional systems.

## Installation

Add `ex_numerlo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_numerlo, "~> 0.3.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc) and published on [HexDocs](https://hexdocs.pm).

## Usage

The sole public interface is `ExNumerlo.convert/2`, which handles encoding, decoding, and cross-system conversion.

### Encoding Integers

To encode an integer (or a list of integers) into a specific numeral system:

```elixir
ExNumerlo.convert(123, to: :devanagari)
# {:ok, "१२३"}

ExNumerlo.convert(2026, to: :roman)
# {:ok, "MMXXVI"}

ExNumerlo.convert([1, 2, 3], to: :roman)
# {:ok, ["I", "II", "III"]}
```

### Decoding Strings

To decode an encoded string back to an integer, use the `to: :integer` option. You can specify the source system or let it be auto-detected:

```elixir
# Explicit source
ExNumerlo.convert("१२३", from: :devanagari, to: :integer)
# {:ok, 123}

# Auto-detection
ExNumerlo.convert("MMXXVI", to: :integer)
# {:ok, 2026}
```

### Cross-System Conversion

Convert directly between two numeral systems without going through an intermediate integer:

```elixir
ExNumerlo.convert("MMXXVI", to: :egyptian)
# {:ok, "𓆼𓆼𓎆𓎆𓏺𓏺𓏺𓏺𓏺𓏺"}

ExNumerlo.convert("͵βκϛ", to: :roman)
# {:ok, "MMXXVI"}
```

### Separator Support

Positional systems support custom separators for grouping:

```elixir
ExNumerlo.convert(1234567, to: :arabic, separator: ",")
# {:ok, "1,234,567"}

ExNumerlo.convert("1.234.567", from: :arabic, to: :integer, separator: ".")
# {:ok, 1234567}
```

## Supported Systems

The following 88 systems are currently supported. Examples show `123` (or a nearby value within each system's range); the range column notes supported inputs.

| System | Kind | Description | Range | Example |
| --- | --- | --- | --- | --- |
| `:adlam` | Base-10 digits | Adlam script numerals, used for the Fulani language in West Africa. | any | `𞥑𞥒𞥓 (123)` |
| `:aegean` | Additive / sign-value | Aegean numerals used by Minoan and Mycenaean civilizations (Linear A/B). Uses distinct glyphs for powers of 10 from 1 to 10,000. | > 0 | `𐄫𐄢𐄙𐄐𐄇 (11,111)` |
| `:arabic` | Base-10 digits | Standard Western Arabic numerals (0-9). The most widely used numeral system in the world today. | any | `123 (123)` |
| `:arabic_abjad` | Additive / sign-value | Arabic abjad numerals, an alphabetic sign-value system assigning values to Arabic letters (alif=1 through ghayn=1000). Used historically for numbering and in Islamic numerology. | > 0 | `قكج (123)` |
| `:arabic_indic` | Base-10 digits | Standard Arabic-Indic numerals used in most of the Arab world. | any | `١٢٣ (123)` |
| `:armenian` | Letter numerals | Classical Armenian alphabetic numerals using uppercase letters, from Ա (ayb=1) to Ք (kʿe=9000). Used in pre-modern Armenian manuscripts and dating. | 1–9999 | `ՍԻԶ (2026)` |
| `:attic` | Additive / sign-value | Ancient Greek acrophonic system where symbols derive from the first letter of the number's name (e.g., Δ for δέκα/10). | > 0 | `ΔΔ𐅃ΙΙ (27)` |
| `:balinese` | Base-10 digits | Balinese script numerals, used for the Balinese language in Indonesia. | any | `᭑᭒᭓ (123)` |
| `:base32` | Programmer | Base-32 system using digits 0-9 and letters A-V. | any | `3R (123)` |
| `:base36` | Programmer | Base-36 system using digits 0-9 and letters A-Z. | any | `3F (123)` |
| `:bengali` | Base-10 digits | Bengali-Assamese numerals used in Bangladesh and the Indian states of West Bengal and Assam. | any | `১২৩ (123)` |
| `:binary` | Programmer | Base-2 (binary) system using the standard digits 0 and 1. | any | `1111011 (123)` |
| `:brahmi` | Base-10 digits | Ancient Brahmi script decimal digits, the ancestor of most modern Indian and Southeast Asian numeral systems. | > 0 | `𑁧𑁨𑁩 (123)` |
| `:burmese` | Base-10 digits | Burmese script numerals, used for the Burmese language in Myanmar. | any | `၁၂၃ (123)` |
| `:chakma` | Base-10 digits | Chakma script numerals, used for the Chakma language in Bangladesh and India. | any | `𑄷𑄸𑄹 (123)` |
| `:cham` | Base-10 digits | Cham script numerals, used for the Cham language in Vietnam and Cambodia. | any | `꫑꫒꫓ (123)` |
| `:cuneiform` | Non-decimal | Babylonian sexagesimal (base-60) positional system using wedges. Values within each digit are additive. | ≥ 0 | `𒁹  𒌋𒌋𒁹𒁹𒁹 (83)` |
| `:cyrillic` | Letter numerals | Early Cyrillic numerals modeled on the Greek alphabetic system, with a myriad-style thousands marker (҂) preceding the unit letters. Used in Old Church Slavonic before Arabic numerals. | 1–9999 | `҂ВКЅ (2026)` |
| `:devanagari` | Base-10 digits | Numerals used with the Devanagari script, common in India for Hindi, Marathi, and Sanskrit. | any | `१२३ (123)` |
| `:duodecimal` | Non-decimal | Base-12 system using Pitman's notation (↊ for 10, ↋ for 11). Often preferred by dozenalists for its divisibility. | any | `↊↋ (131)` |
| `:egyptian` | Additive / sign-value | Ancient Egyptian hieroglyphic numerals. An additive base-10 (sign-value) system using distinct glyphs for powers of ten up to one million. | > 0 | `𓍢𓍢𓎆𓎆𓏺𓏺𓏺 (223)` |
| `:ethiopic` | Hybrid | Ge'ez hierarchical additive-multiplicative system using segments of 100. Used in Ethiopia and Eritrea. | > 0 | `፳፫፻፵፭ (2345)` |
| `:extended_arabic_indic` | Base-10 digits | Eastern Arabic-Indic numerals used primarily for Persian and Urdu. Differs from Arabic-Indic for digits 4, 5, and 6. | any | `۱۲۳ (123)` |
| `:fullwidth` | Base-10 digits | Fixed-width (monospaced) forms of Arabic numerals used in CJK (Chinese, Japanese, Korean) contexts for visual alignment. | any | `１２３ (123)` |
| `:greek` | Letter numerals | Ancient Greek (Milesian/Ionian) alphabetic numerals assigning letters to 1-9, 10-90, and 100-900 (alpha=1, stigma=6, koppa=90, sampi=900), with the keraia marker (͵) before letters for thousands. | 1–9999 | `͵βκϛ (2026)` |
| `:gujarati` | Base-10 digits | Gujarati script numerals, used for the Gujarati language in India. | any | `૧૨૩ (123)` |
| `:gunjala_gondi` | Base-10 digits | Gunjala Gondi script numerals, used for the Gondi language in India. | any | `𑶡𑶢𑶣 (123)` |
| `:gurmukhi` | Base-10 digits | Gurmukhi script numerals, used primarily for the Punjabi language in India. | any | `੧੨੩ (123)` |
| `:han` | Hybrid | Simplified Chinese/Japanese (Han) hybrid numeral system. Multiplicative-additive using units of 10,000. | any | `一万二千三百四十五 (12,345)` |
| `:han_positional` | Base-10 digits | Positional use of Han numerals, common in modern contexts like dates. | any | `二〇二六 (2026)` |
| `:hebrew` | Letter numerals | Hebrew gematria numerals assigning letter values from א (alef=1) to ת (tav=400), with final letter forms for 500-900 (khaf, mem, nun, pe, tsadi). | 1–999 | `קכג (123)` |
| `:hexadecimal` | Programmer | Base-16 (hexadecimal) system using digits 0-9 and letters A-F. | any | `7B (123)` |
| `:javanese` | Base-10 digits | Javanese script numerals, used for the Javanese language in Indonesia. | any | `꧑꧒꧓ (123)` |
| `:kaktovik` | Non-decimal | Kaktovik Inupiaq numerals, a base-20 (vigesimal) system designed by Alaskan Iñupiat to represent their language's oral counting. | ≥ 0 | `𝋆𝋀 (120)` |
| `:kannada` | Base-10 digits | Kannada script numerals, used for the Kannada language in India. | any | `೧೨೩ (123)` |
| `:kayah_li` | Base-10 digits | Kayah Li script numerals, used for the Kayah Li language in Myanmar. | any | `꤁꤂꤃ (123)` |
| `:kharosthi` | Additive / sign-value | Kharosthi numerals (U+10A40+) from ancient Gandhara, with digits for 1-4 and signs for 10, 20, 100, and 1000 combined additively (e.g., 9 written as 4+4+1). | > 0 | `𐩆𐩅𐩂 (123)` |
| `:khmer` | Base-10 digits | Khmer script numerals, used for the Khmer language in Cambodia. | any | `១២៣ (123)` |
| `:lao` | Base-10 digits | Lao script numerals, used for the Lao language in Laos. | any | `໑໒໓ (123)` |
| `:lepcha` | Base-10 digits | Lepcha script numerals, used for the Lepcha language in Sikkim and Darjeeling. | any | `᱁᱂᱃ (123)` |
| `:limbu` | Base-10 digits | Limbu script numerals, used for the Limbu language in Nepal and India. | any | `ᥧᥨᥩ (123)` |
| `:malayalam` | Base-10 digits | Malayalam script numerals, used for the Malayalam language in India. | any | `൧൨൩ (123)` |
| `:masaram_gondi` | Base-10 digits | Masaram Gondi script numerals, another script used for the Gondi language in India. | any | `𑵑𑵒𑵓 (123)` |
| `:math_bold` | Mathematical | Mathematical bold serif digits. Used in mathematical notation to distinguish different types of variables. | any | `𝟏𝟐𝟑 (123)` |
| `:math_double_struck` | Mathematical | Mathematical blackboard bold digits. Commonly used to represent sets like integers (ℤ) or naturals (ℕ). | any | `𝟙𝟚𝟛 (123)` |
| `:math_monospace` | Mathematical | Mathematical fixed-width digits used in specialized mathematical and technical contexts. | any | `𝟷𝟸𝟹 (123)` |
| `:math_sans` | Mathematical | Mathematical sans-serif digits used for clean representation in mathematical expressions. | any | `𝟣𝟤𝟥 (123)` |
| `:math_sans_bold` | Mathematical | Mathematical bold sans-serif digits used for emphasis in mathematical notation. | any | `𝟭𝟮𝟯 (123)` |
| `:mayan` | Non-decimal | Vigesimal (base-20) positional system used by the Maya civilization. Uses a shell for zero, dots for 1, and bars for 5. | ≥ 0 | `𝋡𝋠 (20)` |
| `:meetei_mayek` | Base-10 digits | Meetei Mayek script numerals, used for the Meiteilon (Manipuri) language in India. | any | `꯱꯲꯳ (123)` |
| `:modi` | Base-10 digits | Modi script numerals, historically used to write the Marathi language in India. | any | `𑙑𑙒𑙓 (123)` |
| `:mongolian` | Base-10 digits | Traditional Mongolian script numerals, used in Inner Mongolia (China) and Mongolia. | any | `᠑᠒᠓ (123)` |
| `:mro` | Base-10 digits | Mro script numerals, used for the Mro language in Bangladesh and Myanmar. | any | `𖩡𖩢𖩣 (123)` |
| `:n_ko` | Base-10 digits | N'Ko script numerals, used for the Manding languages in West Africa. | any | `߁߂߃ (123)` |
| `:nag_mundari` | Base-10 digits | Nag Mundari script numerals, used for the Mundari language in India. | any | `𞓱𞓲𞓳 (123)` |
| `:new_tai_lue` | Base-10 digits | New Tai Lue script numerals, used for the Tai Lue language in China and Southeast Asia. | any | `᧑᧒᧓ (123)` |
| `:nyiakeng_puachue_hmong` | Base-10 digits | Nyiakeng Puachue Hmong script numerals, another script used for the Hmong language. | any | `𞅁𞅂𞅃 (123)` |
| `:octal` | Programmer | Base-8 (octal) system using the standard digits 0-7. | any | `173 (123)` |
| `:ol_chiki` | Base-10 digits | Ol Chiki script numerals, used for the Santali language in India and Bangladesh. | any | `᱑᱒᱓ (123)` |
| `:oriya` | Base-10 digits | Oriya (Odia) script numerals, used for the Odia language in India. | any | `୧୨୩ (123)` |
| `:osmanya` | Base-10 digits | Osmanya script numerals, an alphabetic script used for the Somali language in Somalia. | any | `𐒡𐒢𐒣 (123)` |
| `:pahawh_hmong` | Base-10 digits | Pahawh Hmong script numerals, used for the Hmong language in Laos and Thailand. | any | `𖭑𖭒𖭓 (123)` |
| `:rod` | Base-10 digits | Counting rod numerals, an ancient positional system using vertical and horizontal strokes. | any | `𝍠𝍩𝍢 (123)` |
| `:roman` | Additive / sign-value | Standard Roman numerals using additive/subtractive notation. Limited to the range 1-3999 in standard Unicode representation. | 1–3999 | `MMXXVI (2026)` |
| `:rumi` | Additive / sign-value | Rumi (Fez) numerals (U+10E60+), a distinct sign-value system historically used in North Africa (Morocco) for dates and financial reckoning. | > 0 | `𐹲𐹪𐹢 (123)` |
| `:saurashtra` | Base-10 digits | Saurashtra script numerals, used for the Saurashtra language in Southern India. | any | `꣑꣒꣓ (123)` |
| `:sharada` | Base-10 digits | Sharada script numerals, an ancient script used in Kashmir. | any | `𑇑𑇒𑇓 (123)` |
| `:sinhala` | Base-10 digits | Sinhala (Lith) script numerals, used primarily for the Sinhala language in Sri Lanka. | any | `෧෨෩ (123)` |
| `:sinhala_archaic` | Additive / sign-value | Archaic Sinhala numerals (U+111E0+), an additive sign-value system historically used in Sri Lanka before the modern Sinhala script digits. | > 0 | `𑇳𑇫𑇣 (123)` |
| `:siyaq_indic` | Additive / sign-value | Indic Siyaq accounting numerals (U+1EC70+) used in Mughal-era India and Persia for documents and currency, with distinct glyphs per digit place up to ten-thousands. | 1–99999 | `𞲍𞱻𞱶 (2026)` |
| `:siyaq_ottoman` | Additive / sign-value | Ottoman Siyaq accounting numerals (U+1ED00+) used in Ottoman Turkish financial documents, with distinct glyphs per digit place up to ten-thousands. | 1–99999 | `𞴝𞴋𞴆 (2026)` |
| `:sora_sompeng` | Base-10 digits | Sora Sompeng script numerals, used for the Sora language in India. | any | `𑃱𑃲𑃳 (123)` |
| `:sundanese` | Base-10 digits | Sundanese script numerals, used for the Sundanese language in Indonesia. | any | `᮱᮲᮳ (123)` |
| `:suzhou` | Base-10 digits | Suzhou numerals (huama), a shorthand numeral system once common in Chinese markets. | any | `〡〢〣 (123)` |
| `:tai_tham_hora` | Base-10 digits | Tai Tham script numerals (Hora style), used for secular purposes in Northern Thailand and Laos. | any | `᪑᪒᪓ (123)` |
| `:tai_tham_tham` | Base-10 digits | Tai Tham script numerals (Tham style), used for religious purposes in Northern Thailand and Laos. | any | `᪡᪢᪣ (123)` |
| `:takri` | Base-10 digits | Takri script numerals, used for various languages in the Western Himalayas. | any | `𑛁𑛂𑛃 (123)` |
| `:tamil` | Base-10 digits | Tamil script numerals, used for the Tamil language in India and Sri Lanka. | any | `௧௨௩ (123)` |
| `:tamil_traditional` | Additive / sign-value | Traditional Tamil numerals combining unit digits (௧-௯) with distinct ten, hundred, and thousand signs (௰, ௱, ௲). The predecessor of the modern positional Tamil digits. | > 0 | `௱௰௰௩ (123)` |
| `:tangsa` | Base-10 digits | Tangsa script numerals, used for the Tangsa language in India and Myanmar. | any | `𖫁𖫂𖫃 (123)` |
| `:telugu` | Base-10 digits | Telugu script numerals, used for the Telugu language in India. | any | `౧౨౩ (123)` |
| `:thai` | Base-10 digits | Thai script numerals, used alongside Western Arabic numerals in Thailand. | any | `๑๒๓ (123)` |
| `:tibetan` | Base-10 digits | Tibetan script numerals, used in Tibet and surrounding regions. | any | `༡༢༣ (123)` |
| `:tirhuta` | Base-10 digits | Tirhuta script numerals, used for the Maithili language in India and Nepal. | any | `𑓑𑓒𑓓 (123)` |
| `:toto` | Base-10 digits | Toto script numerals, used for the Toto language in India. | any | `𞊑𞊒𞊓 (123)` |
| `:vai` | Base-10 digits | Vai script numerals, a syllabic script used for the Vai language in Liberia. | any | `꘡꘢꘣ (123)` |
| `:wancho` | Base-10 digits | Wancho script numerals, used for the Wancho language in India. | any | `𞋱𞋲𞋳 (123)` |
| `:warang_citi` | Base-10 digits | Warang Citi script numerals, used for the Ho language in India. | any | `𑣡𑣢𑣣 (123)` |

## LLM Agent Instructions

Usage rules for LLM agents are provided in `usage-rules.md` for integration with the `usage_rules` tool.
