defmodule ExNumerloScriptsTest do
  use ExUnit.Case, async: true

  @examples [
    {:arabic, 123, "123"},
    {:arabic_indic, 123, "١٢٣"},
    {:extended_arabic_indic, 123, "۱۲۳"},
    {:devanagari, 123, "१२३"},
    {:bengali, 123, "১২৩"},
    {:gurmukhi, 123, "੧੨੩"},
    {:gujarati, 123, "૧૨૩"},
    {:oriya, 123, "୧୨୩"},
    {:tamil, 123, "௧௨௩"},
    {:telugu, 123, "౧౨౩"},
    {:kannada, 123, "೧೨೩"},
    {:malayalam, 123, "൧൨൩"},
    {:thai, 123, "๑๒๓"},
    {:lao, 123, "໑໒໓"},
    {:tibetan, 123, "༡༢༣"},
    {:burmese, 123, "၁၂၃"},
    {:khmer, 123, "១២៣"},
    {:mongolian, 123, "᠑᠒᠓"},
    {:limbu, 123, "᥁᥂᥃"},
    {:new_tai_lue, 123, "᧑᧒᧓"},
    {:tai_tham_hora, 123, "᪁᪂᪃"},
    {:tai_tham_tham, 123, "᪑᪒᪓"},
    {:balinese, 123, "᭑᭒᭓"},
    {:sundanese, 123, "᮱᮲᮳"},
    {:lepcha, 123, "᱁᱂᱃"},
    {:ol_chiki, 123, "᱑᱒᱓"},
    {:vai, 123, "꘡꘢꘣"},
    {:saurashtra, 123, "꣑꣒꣓"},
    {:kayah_li, 123, "꤁꤂꤃"},
    {:javanese, 123, "꧑꧒꧓"},
    {:cham, 123, "꩑꩒꩓"},
    {:meetei_mayek, 123, "꯱꯲꯳"},
    {:osmanya, 123, "𐒡𐒢𐒣"},
    {:brahmi, 123, "𑁧𑁨𑁩"},
    {:sora_sompeng, 123, "𑃱𑃲𑃳"},
    {:chakma, 123, "𑄷𑄸𑄹"},
    {:sharada, 123, "𑇑𑇒𑇓"},
    {:tirhuta, 123, "𑓑𑓒𑓓"},
    {:modi, 123, "𑙑𑙒𑙓"},
    {:takri, 123, "𑛁𑛂𑛃"},
    {:warang_citi, 123, "𑣡𑣢𑣣"},
    {:gunjala_gondi, 123, "𑶑𑶒𑶓"},
    {:masaram_gondi, 123, "𑻱𑻲𑻳"},
    {:kaktovik, 123, "𝋆𝋃"},
    {:mro, 123, "𖩡𖩢𖩣"},
    {:tangsa, 123, "𖫁𖫂𖫃"},
    {:pahawh_hmong, 123, "𖭑𖭒𖭓"},
    {:nyiakeng_puachue_hmong, 123, "𞅁𞅂𞅃"},
    {:wancho, 123, "𞋱𞋲𞋳"},
    {:nag_mundari, 123, "𞓱𞓲𞓳"},
    {:adlam, 123, "𞥑𞥒𞥓"},
    {:n_ko, 123, "߁߂߃"},
    {:toto, 123, "𞊑𞊒𞊓"},
    {:han_positional, 123, "一二三"},
    {:suzhou, 123, "〡〢〣"},
    # Rod Vertical 1: 𝍠, Horizontal 10: 𝍪 (2), Vertical 100: 𝍠 (1)
    {:rod, 123, "𝍠𝍪𝍢"},
    {:fullwidth, 123, "１２３"},
    {:math_bold, 123, "𝟏𝟐𝟑"},
    {:math_double_struck, 123, "𝟙𝟚𝟛"},
    {:math_monospace, 123, "𝟷𝟸𝟹"},
    {:math_sans, 123, "𝟣𝟤𝟥"},
    {:math_sans_bold, 123, "𝟭𝟮𝟯"},
    {:hexadecimal, 123, "7B"}
  ]

  describe "positional systems" do
    test "round-trip for all positional systems" do
      for {sys, n, expected} <- @examples do
        assert {:ok, res} = ExNumerlo.convert(n, to: sys), "Failed to encode #{sys}"

        assert res == expected,
               "Encoded result mismatch for #{sys}: expected #{inspect(expected)}, got #{inspect(res)}"

        assert {:ok, ^n} = ExNumerlo.convert(expected, from: sys, to: :integer),
               "Failed to decode #{sys}"
      end
    end

    test "auto-detection for all positional systems" do
      for {sys, n, expected} <- @examples do
        # Systems with unique glyphs should auto-detect correctly.
        # Arabic is the default fallback for 0-9 digits.
        unless sys == :arabic do
          case ExNumerlo.convert(expected, to: :integer) do
            {:ok, val} ->
              assert val == n,
                     "Auto-detect value mismatch for #{sys} (#{inspect(expected)}): expected #{n}, got #{val}"

            {:error, reason} ->
              flunk("Failed to auto-detect #{sys} (#{inspect(expected)}): #{inspect(reason)}")
          end
        end
      end
    end
  end

  describe "han hybrid numeral system" do
    test "encodes with myriad-based multiplicative notation" do
      assert ExNumerlo.convert(12_345, to: :han) == {:ok, "一万二千三百四十五"}
      assert ExNumerlo.convert(1001, to: :han) == {:ok, "一千零一"}
      assert ExNumerlo.convert(10_000, to: :han) == {:ok, "一万"}
      assert ExNumerlo.convert(0, to: :han) == {:ok, "零"}
      assert ExNumerlo.convert(-123, to: :han) == {:ok, "负一百二十三"}
    end
  end
end
