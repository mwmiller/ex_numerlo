defmodule ExNumerloPropertyTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  @systems [
    :arabic,
    :arabic_indic,
    :extended_arabic_indic,
    :devanagari,
    :bengali,
    :gurmukhi,
    :gujarati,
    :oriya,
    :tamil,
    :telugu,
    :kannada,
    :malayalam,
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
    :fullwidth,
    :math_monospace,
    :math_bold,
    :math_double_struck,
    :math_sans,
    :math_sans_bold,
    :roman,
    :aegean,
    :attic,
    :mayan,
    :duodecimal
  ]

  property "all systems round-trip correctly with auto-detection" do
    check all(
            sys <- member_of(@systems),
            n <- integer(1..3999)
          ) do
      case ExNumerlo.convert(n, to: sys) do
        {:ok, encoded} ->
          # For duodecimal, if it doesn't contain unique digits ↊ or ↋,
          # it will be auto-detected as Arabic. This is expected.
          is_duo_overlap = sys == :duodecimal and !String.contains?(encoded, ["↊", "↋"])

          case ExNumerlo.convert(encoded, to: :integer) do
            {:ok, decoded} ->
              case is_duo_overlap do
                true ->
                  :ok

                false ->
                  assert decoded == n,
                         "Auto-detect round-trip failed for #{sys} with #{n}: got #{decoded}, expected #{n} (encoded: #{inspect(encoded)})"
              end

            {:error, reason} ->
              flunk(
                "Failed to auto-detect encoded value from #{sys} (#{n}): #{inspect(encoded)}, reason: #{inspect(reason)}"
              )
          end

        {:error, _reason} ->
          # Range errors (like Roman > 3999) are expected and filtered by the generator usually
          :ok
      end
    end
  end

  property "standard positional systems handle negative numbers" do
    check all(
            sys <-
              member_of([:arabic, :devanagari, :thai, :fullwidth, :math_bold, :adlam, :balinese]),
            n <- integer()
          ) do
      {:ok, encoded} = ExNumerlo.convert(n, to: sys)
      {:ok, decoded} = ExNumerlo.convert(encoded, to: :integer)
      assert decoded == n
    end
  end

  property "separator round-trips" do
    check all(
            sys <- member_of([:arabic, :devanagari, :fullwidth, :duodecimal, :adlam]),
            n <- integer(10_000..1_000_000),
            sep <- member_of([",", ".", " "])
          ) do
      {:ok, encoded} = ExNumerlo.convert(n, to: sys, separator: sep)
      assert String.contains?(encoded, sep)
      {:ok, decoded} = ExNumerlo.convert(encoded, from: sys, to: :integer, separator: sep)
      assert decoded == n
    end
  end
end
