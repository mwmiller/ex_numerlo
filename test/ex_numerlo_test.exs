defmodule ExNumerloTest do
  use ExUnit.Case
  doctest ExNumerlo

  alias ExNumerlo.System.Arabic
  alias ExNumerlo.System.ArabicAbjad
  alias ExNumerlo.System.Armenian
  alias ExNumerlo.System.Cyrillic
  alias ExNumerlo.System.Duodecimal
  alias ExNumerlo.System.Greek
  alias ExNumerlo.System.Hebrew
  alias ExNumerlo.System.Historical.Aegean
  alias ExNumerlo.System.Historical.Attic
  alias ExNumerlo.System.Historical.Cuneiform
  alias ExNumerlo.System.Historical.Egyptian
  alias ExNumerlo.System.Historical.Ethiopic
  alias ExNumerlo.System.Historical.Mayan
  alias ExNumerlo.System.Kharosthi
  alias ExNumerlo.System.Roman
  alias ExNumerlo.System.Rumi
  alias ExNumerlo.System.SinhalaArchaic
  alias ExNumerlo.System.SiyaqIndic
  alias ExNumerlo.System.SiyaqOttoman
  alias ExNumerlo.System.TamilTraditional

  test "systems/0 returns metadata map with consistent keys" do
    meta = ExNumerlo.systems()
    assert is_map(meta)

    for {sys, data} <- meta do
      assert is_map(data), "Metadata for #{sys} should be a map"
      assert Map.has_key?(data, :description), "Metadata for #{sys} should have :description"
      assert Map.has_key?(data, :base), "Metadata for #{sys} should have :base"
      assert Map.has_key?(data, :type), "Metadata for #{sys} should have :type"
      assert Map.has_key?(data, :range), "Metadata for #{sys} should have :range"
    end

    assert meta.arabic.base == 10
    assert meta.roman.range == 1..3999
    assert meta.mayan.base == 20
    assert meta.cuneiform.base == 60
    assert meta.duodecimal.base == 12
    assert meta.ethiopic.type == :hybrid
  end

  test "encodes arabic (default)" do
    assert ExNumerlo.convert(123, to: :arabic) == {:ok, "123"}
    assert ExNumerlo.convert(-45, to: :arabic) == {:ok, "-45"}
    assert ExNumerlo.convert(0, to: :arabic) == {:ok, "0"}
  end

  test "handles positive sign in decoding" do
    assert {:ok, 123} == ExNumerlo.convert("+123", from: :arabic, to: :integer)
    assert {:ok, 123} == ExNumerlo.convert("+१२३", from: :devanagari, to: :integer)
  end

  test "handles empty separator" do
    assert {:ok, "1234"} == ExNumerlo.convert(1234, to: :arabic, separator: "")
  end

  test "encodes devanagari" do
    assert ExNumerlo.convert(123, to: :devanagari) == {:ok, "१२३"}
    assert ExNumerlo.convert(0, to: :devanagari) == {:ok, "०"}
  end

  test "encodes thai" do
    assert ExNumerlo.convert(123, to: :thai) == {:ok, "๑๒๓"}
  end

  test "encodes and decodes sinhala" do
    assert {:ok, "෧෨෩"} == ExNumerlo.convert(123, to: :sinhala)
    assert {:ok, "෦"} == ExNumerlo.convert(0, to: :sinhala)
    assert {:ok, 123} == ExNumerlo.convert("෧෨෩", from: :sinhala, to: :integer)
    assert {:ok, 123} == ExNumerlo.convert("෧෨෩", to: :integer)
  end

  test "encodes roman numerals" do
    assert ExNumerlo.convert(1, to: :roman) == {:ok, "I"}
    assert ExNumerlo.convert(14, to: :roman) == {:ok, "XIV"}
    assert ExNumerlo.convert(2026, to: :roman) == {:ok, "MMXXVI"}
  end

  test "roman numerals range errors" do
    assert {:error, :not_positive} == ExNumerlo.convert(0, to: :roman)
    assert {:error, :not_positive} == ExNumerlo.convert(-1, to: :roman)
    assert {:error, :out_of_range} == ExNumerlo.convert(4000, to: :roman)
  end

  test "encodes lists of integers" do
    assert ExNumerlo.convert([1, 2, 3], to: :roman) == {:ok, ["I", "II", "III"]}
  end

  test "encodes and decodes aegean" do
    assert ExNumerlo.convert(42, to: :aegean) == {:ok, "𐄓𐄈"}
    # 1: 𐄇, 10: 𐄐, 100: 0x10119 (𐄙), 1000: 0x10122 (𐄢), 10000: 0x1012B (𐄫)
    assert {:ok, "𐄢"} == ExNumerlo.convert(1000, to: :aegean)
    assert {:ok, "𐄫"} == ExNumerlo.convert(10_000, to: :aegean)
    assert {:ok, 1000} == ExNumerlo.convert("𐄢", to: :integer)
    assert {:ok, 10_000} == ExNumerlo.convert("𐄫", to: :integer)
  end

  test "encodes and decodes attic" do
    # 49 = 40 (ΔΔΔΔ) + 5 (𐅃) + 4 (ΙΙΙΙ)
    assert {:ok, "ΔΔΔΔ𐅃ΙΙΙΙ"} == ExNumerlo.convert(49, to: :attic)
    # 2001 = 2000 (ΧΧ) + 1 (Ι)
    assert {:ok, "ΧΧΙ"} == ExNumerlo.convert(2001, to: :attic)

    assert {:ok, 49} == ExNumerlo.convert("ΔΔΔΔ𐅃ΙΙΙΙ", to: :integer)
    assert {:ok, 2001} == ExNumerlo.convert("ΧΧΙ", to: :integer)
  end

  test "encodes and decodes egyptian" do
    assert {:ok, "𓏺"} == ExNumerlo.convert(1, to: :egyptian)
    assert {:ok, "𓎆"} == ExNumerlo.convert(10, to: :egyptian)
    assert {:ok, "𓍢𓎆𓎆𓏺𓏺𓏺"} == ExNumerlo.convert(123, to: :egyptian)
    assert {:ok, "𓁨"} == ExNumerlo.convert(1_000_000, to: :egyptian)

    assert {:ok, 123} == ExNumerlo.convert("𓍢𓎆𓎆𓏺𓏺𓏺", from: :egyptian, to: :integer)
    assert {:ok, 11} == ExNumerlo.convert("𓏺𓎆", to: :integer)
    assert {:error, :not_positive} == ExNumerlo.convert(0, to: :egyptian)
  end

  test "encodes and decodes mayan" do
    assert ExNumerlo.convert(20, to: :mayan) == {:ok, "𝋡𝋠"}
    # 13: 𝋭
    assert {:ok, "𝋭"} == ExNumerlo.convert(13, to: :mayan)
    # 33: (1*20) + 13 = 𝋡𝋭
    assert {:ok, "𝋡𝋭"} == ExNumerlo.convert(33, to: :mayan)
    # 429: (1*400) + (1*20) + 9 = 𝋡𝋡𝋩
    assert {:ok, "𝋡𝋡𝋩"} == ExNumerlo.convert(429, to: :mayan)

    assert {:ok, 13} == ExNumerlo.convert("𝋭", to: :integer)
    assert {:ok, 33} == ExNumerlo.convert("𝋡𝋭", to: :integer)
    assert {:ok, 429} == ExNumerlo.convert("𝋡𝋡𝋩", to: :integer)
  end

  test "detect? handles empty string" do
    refute Arabic.detect?("")
    refute Roman.detect?("")
    refute Aegean.detect?("")
    refute Attic.detect?("")
    refute Egyptian.detect?("")
    refute Mayan.detect?("")
    refute Ethiopic.detect?("")
    refute Cuneiform.detect?("")
    refute Greek.detect?("")
    refute Armenian.detect?("")
    refute Hebrew.detect?("")
    refute Cyrillic.detect?("")
    refute ArabicAbjad.detect?("")
    refute TamilTraditional.detect?("")
    refute SinhalaArchaic.detect?("")
    refute Kharosthi.detect?("")
    refute Rumi.detect?("")
    refute SiyaqIndic.detect?("")
    refute SiyaqOttoman.detect?("")
  end

  test "ethiopic large numbers and decoding" do
    assert {:ok, "፼"} == ExNumerlo.convert(10_000, to: :ethiopic)
    assert {:ok, "፪፼"} == ExNumerlo.convert(20_000, to: :ethiopic)
    assert {:ok, "፻፼"} == ExNumerlo.convert(1_000_000, to: :ethiopic)

    assert {:ok, 123} == ExNumerlo.convert("፻፳፫", from: :ethiopic, to: :integer)
    assert {:ok, 10_000} == ExNumerlo.convert("፼", from: :ethiopic, to: :integer)
    assert {:ok, 20_000} == ExNumerlo.convert("፪፼", from: :ethiopic, to: :integer)

    # ፼፼ is interpreted as ((0 + 1) * 10,000 + 1) * 10,000 = 100,010,000
    assert {:ok, 100_010_000} == ExNumerlo.convert("፼፼", from: :ethiopic, to: :integer)

    # 2345: ፳፫፻፵፭
    assert {:ok, "፳፫፻፵፭"} == ExNumerlo.convert(2345, to: :ethiopic)
    assert {:ok, 2345} == ExNumerlo.convert("፳፫፻፵፭", from: :ethiopic, to: :integer)
  end

  test "cuneiform zero gap and decoding" do
    assert {:ok, "𒁹   "} == ExNumerlo.convert(60, to: :cuneiform)
    assert {:ok, 60} == ExNumerlo.convert("𒁹   ", from: :cuneiform, to: :integer)
    assert {:ok, 3600} == ExNumerlo.convert("𒁹     ", from: :cuneiform, to: :integer)

    # 23: 𒌋𒌋𒁹𒁹𒁹
    assert {:ok, "𒌋𒌋𒁹𒁹𒁹"} == ExNumerlo.convert(23, to: :cuneiform)
    assert {:ok, 23} == ExNumerlo.convert("𒌋𒌋𒁹𒁹𒁹", from: :cuneiform, to: :integer)

    # 8583 = 2 * 3600 + 23 * 60 + 3
    # Digits: 2, 23, 3
    assert {:ok, "𒁹𒁹  𒌋𒌋𒁹𒁹𒁹  𒁹𒁹𒁹"} == ExNumerlo.convert(8583, to: :cuneiform)
    assert {:ok, 8583} == ExNumerlo.convert("𒁹𒁹  𒌋𒌋𒁹𒁹𒁹  𒁹𒁹𒁹", from: :cuneiform, to: :integer)
  end

  test "error returns for invalid inputs" do
    assert {:error, :invalid_digit} == ExNumerlo.convert("12A", from: :arabic, to: :integer)

    assert {:error, :invalid_roman_numeral} ==
             ExNumerlo.convert("ABC", from: :roman, to: :integer)

    assert {:error, :invalid_aegean_numeral} ==
             ExNumerlo.convert("A", from: :aegean, to: :integer)

    assert {:error, :invalid_attic_numeral} == ExNumerlo.convert("A", from: :attic, to: :integer)

    assert {:error, :invalid_egyptian_numeral} ==
             ExNumerlo.convert("A", from: :egyptian, to: :integer)

    assert {:error, :invalid_mayan_numeral} == ExNumerlo.convert("A", from: :mayan, to: :integer)

    assert {:error, :invalid_ethiopic_numeral} ==
             ExNumerlo.convert("A", from: :ethiopic, to: :integer)

    assert {:error, :invalid_cuneiform_numeral} ==
             ExNumerlo.convert("A", from: :cuneiform, to: :integer)

    assert {:error, :invalid_greek_numeral} == ExNumerlo.convert("A", from: :greek, to: :integer)

    assert {:error, :invalid_armenian_numeral} ==
             ExNumerlo.convert("A", from: :armenian, to: :integer)

    assert {:error, :invalid_hebrew_numeral} ==
             ExNumerlo.convert("A", from: :hebrew, to: :integer)

    assert {:error, :invalid_cyrillic_numeral} ==
             ExNumerlo.convert("A", from: :cyrillic, to: :integer)

    assert {:error, :invalid_abjad_numeral} ==
             ExNumerlo.convert("A", from: :arabic_abjad, to: :integer)

    assert {:error, :invalid_tamil_traditional_numeral} ==
             ExNumerlo.convert("A", from: :tamil_traditional, to: :integer)

    assert {:error, :invalid_sinhala_archaic_numeral} ==
             ExNumerlo.convert("A", from: :sinhala_archaic, to: :integer)

    assert {:error, :invalid_kharosthi_numeral} ==
             ExNumerlo.convert("A", from: :kharosthi, to: :integer)

    assert {:error, :invalid_rumi_numeral} == ExNumerlo.convert("A", from: :rumi, to: :integer)

    assert {:error, :invalid_siyaq_indic_numeral} ==
             ExNumerlo.convert("A", from: :siyaq_indic, to: :integer)

    assert {:error, :invalid_siyaq_ottoman_numeral} ==
             ExNumerlo.convert("A", from: :siyaq_ottoman, to: :integer)

    assert {:error, :invalid_digit} == ExNumerlo.convert("A", from: :duodecimal, to: :integer)
  end

  test "detect? with mixed content" do
    refute Roman.detect?("IIA")
    refute Arabic.detect?("12A")
    refute Duodecimal.detect?("↊A")
    refute Mayan.detect?("𝋠A")
  end

  test "roman edge cases" do
    assert {:ok, "MMMCMXCIX"} == ExNumerlo.convert(3999, to: :roman)
    assert {:ok, 3999} == ExNumerlo.convert("MMMCMXCIX", from: :roman, to: :integer)
  end

  test "duodecimal detection edge cases" do
    # Only digits 0-9
    refute Duodecimal.detect?("123")
    # All digits but no 10/11
    refute Duodecimal.detect?("1")
    # Valid
    assert Duodecimal.detect?("↊")
  end

  test "convert returns error on unknown system" do
    assert {:error, :unknown_system} == ExNumerlo.convert(1, to: :unknown)
    assert {:error, :unknown_system} == ExNumerlo.convert("1", from: :unknown, to: :integer)
  end

  test "encodes and decodes binary" do
    assert {:ok, "0"} == ExNumerlo.convert(0, to: :binary)
    assert {:ok, "1"} == ExNumerlo.convert(1, to: :binary)
    assert {:ok, "101"} == ExNumerlo.convert(5, to: :binary)
    assert {:ok, "1111011"} == ExNumerlo.convert(123, to: :binary)

    assert {:ok, 0} == ExNumerlo.convert("0", from: :binary, to: :integer)
    assert {:ok, 123} == ExNumerlo.convert("1111011", from: :binary, to: :integer)
  end

  test "encodes and decodes octal" do
    assert {:ok, "0"} == ExNumerlo.convert(0, to: :octal)
    assert {:ok, "173"} == ExNumerlo.convert(123, to: :octal)

    assert {:ok, 123} == ExNumerlo.convert("173", from: :octal, to: :integer)
  end

  test "encodes and decodes hexadecimal" do
    assert {:ok, "0"} == ExNumerlo.convert(0, to: :hexadecimal)
    assert {:ok, "7B"} == ExNumerlo.convert(123, to: :hexadecimal)
    assert {:ok, "FF"} == ExNumerlo.convert(255, to: :hexadecimal)
    assert {:ok, "2A"} == ExNumerlo.convert(42, to: :hexadecimal)

    assert {:ok, 123} == ExNumerlo.convert("7B", from: :hexadecimal, to: :integer)
    assert {:ok, 255} == ExNumerlo.convert("FF", from: :hexadecimal, to: :integer)
    assert {:ok, 42} == ExNumerlo.convert("2A", from: :hexadecimal, to: :integer)
  end

  test "hexadecimal auto-detection" do
    assert {:ok, 255} == ExNumerlo.convert("FF", to: :integer)
    assert {:ok, 42} == ExNumerlo.convert("2A", to: :integer)
  end

  test "programmer bases support negative numbers and separators" do
    assert {:ok, "-FF"} == ExNumerlo.convert(-255, to: :hexadecimal)
    assert {:ok, -255} == ExNumerlo.convert("-FF", from: :hexadecimal, to: :integer)
    assert {:ok, "10,101"} == ExNumerlo.convert(21, to: :binary, separator: ",")
    assert {:ok, 21} == ExNumerlo.convert("10,101", from: :binary, to: :integer, separator: ",")
  end

  test "programmer bases reject invalid digits" do
    assert {:error, :invalid_digit} == ExNumerlo.convert("2", from: :binary, to: :integer)
    assert {:error, :invalid_digit} == ExNumerlo.convert("8", from: :octal, to: :integer)
    assert {:error, :invalid_digit} == ExNumerlo.convert("G", from: :hexadecimal, to: :integer)
  end

  test "encodes and decodes base32" do
    assert {:ok, "0"} == ExNumerlo.convert(0, to: :base32)
    assert {:ok, "A"} == ExNumerlo.convert(10, to: :base32)
    assert {:ok, "V"} == ExNumerlo.convert(31, to: :base32)
    assert {:ok, "10"} == ExNumerlo.convert(32, to: :base32)
    assert {:ok, "3R"} == ExNumerlo.convert(123, to: :base32)

    assert {:ok, 123} == ExNumerlo.convert("3R", from: :base32, to: :integer)
    assert {:ok, 123} == ExNumerlo.convert("3R", to: :integer)
  end

  test "encodes and decodes base36" do
    assert {:ok, "0"} == ExNumerlo.convert(0, to: :base36)
    assert {:ok, "Z"} == ExNumerlo.convert(35, to: :base36)
    assert {:ok, "10"} == ExNumerlo.convert(36, to: :base36)
    assert {:ok, "3F"} == ExNumerlo.convert(123, to: :base36)
    assert {:ok, "X0"} == ExNumerlo.convert(1188, to: :base36)

    assert {:ok, 123} == ExNumerlo.convert("3F", from: :base36, to: :integer)
    assert {:ok, 1188} == ExNumerlo.convert("X0", to: :integer)
  end

  test "base32 and base36 auto-detection requires unique letters" do
    assert {:error, :invalid_digit} == ExNumerlo.convert("W2", from: :base32, to: :integer)
    assert {:ok, 68} == ExNumerlo.convert("1W", to: :integer)
    assert {:ok, 60} == ExNumerlo.convert("1S", to: :integer)
  end

  test "encodes and decodes greek" do
    assert {:ok, "ρκγ"} == ExNumerlo.convert(123, to: :greek)
    assert {:ok, "͵βκϛ"} == ExNumerlo.convert(2026, to: :greek)
    assert {:ok, "͵α"} == ExNumerlo.convert(1000, to: :greek)
    assert {:ok, 2026} == ExNumerlo.convert("͵βκϛ", to: :integer)
    assert {:ok, 123} == ExNumerlo.convert("ρκγ", from: :greek, to: :integer)
    assert {:error, :not_positive} == ExNumerlo.convert(0, to: :greek)
    assert {:error, :out_of_range} == ExNumerlo.convert(10_000, to: :greek)
  end

  test "encodes and decodes armenian" do
    assert {:ok, "ՃԻԳ"} == ExNumerlo.convert(123, to: :armenian)
    assert {:ok, "ՍԻԶ"} == ExNumerlo.convert(2026, to: :armenian)
    assert {:ok, 2026} == ExNumerlo.convert("ՍԻԶ", to: :integer)
  end

  test "encodes and decodes hebrew" do
    assert {:ok, "קכג"} == ExNumerlo.convert(123, to: :hebrew)
    assert {:ok, "קצט"} == ExNumerlo.convert(199, to: :hebrew)
    assert {:ok, 199} == ExNumerlo.convert("קצט", from: :hebrew, to: :integer)
    assert {:ok, 123} == ExNumerlo.convert("קכג", to: :integer)
    assert {:error, :out_of_range} == ExNumerlo.convert(1000, to: :hebrew)
  end

  test "encodes and decodes cyrillic" do
    assert {:ok, "РКГ"} == ExNumerlo.convert(123, to: :cyrillic)
    assert {:ok, "҂ВКЅ"} == ExNumerlo.convert(2026, to: :cyrillic)
    assert {:ok, 2026} == ExNumerlo.convert("҂ВКЅ", to: :integer)
  end

  test "encodes and decodes arabic abjad" do
    assert {:ok, "قكج"} == ExNumerlo.convert(123, to: :arabic_abjad)
    assert {:ok, "غغكو"} == ExNumerlo.convert(2026, to: :arabic_abjad)
    assert {:ok, 2026} == ExNumerlo.convert("غغكو", to: :integer)
  end

  test "encodes and decodes tamil traditional" do
    assert {:ok, "௱௰௰௩"} == ExNumerlo.convert(123, to: :tamil_traditional)
    assert {:ok, "௲௲௰௰௬"} == ExNumerlo.convert(2026, to: :tamil_traditional)
    assert {:ok, 2026} == ExNumerlo.convert("௲௲௰௰௬", to: :integer)
  end

  test "encodes and decodes sinhala archaic" do
    assert {:ok, "𑇳𑇫𑇣"} == ExNumerlo.convert(123, to: :sinhala_archaic)
    assert {:ok, "𑇴𑇴𑇫𑇦"} == ExNumerlo.convert(2026, to: :sinhala_archaic)
    assert {:ok, 2026} == ExNumerlo.convert("𑇴𑇴𑇫𑇦", to: :integer)
  end

  test "encodes and decodes kharosthi" do
    assert {:ok, "𐩆𐩅𐩂"} == ExNumerlo.convert(123, to: :kharosthi)
    assert {:ok, 123} == ExNumerlo.convert("𐩆𐩅𐩂", to: :integer)
  end

  test "encodes and decodes rumi" do
    assert {:ok, "𐹲𐹪𐹢"} == ExNumerlo.convert(123, to: :rumi)
    assert {:ok, 123} == ExNumerlo.convert("𐹲𐹪𐹢", to: :integer)
  end

  test "encodes and decodes siyaq systems" do
    assert {:ok, "𞲃𞱻𞱳"} == ExNumerlo.convert(123, to: :siyaq_indic)
    assert {:ok, "𞲍𞱻𞱶"} == ExNumerlo.convert(2026, to: :siyaq_indic)
    assert {:ok, 2026} == ExNumerlo.convert("𞲍𞱻𞱶", to: :integer)

    assert {:ok, "𞴓𞴋𞴃"} == ExNumerlo.convert(123, to: :siyaq_ottoman)
    assert {:ok, "𞴝𞴋𞴆"} == ExNumerlo.convert(2026, to: :siyaq_ottoman)
    assert {:ok, 2026} == ExNumerlo.convert("𞴝𞴋𞴆", to: :integer)
  end
end
