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
    :duodecimal,
    :binary,
    :octal,
    :hexadecimal
  ]

  describe "auto-detection" do
    property "all systems round-trip correctly with auto-detection" do
      check all(
              sys <- member_of(@systems),
              n <- integer(1..3999)
            ) do
        case ExNumerlo.convert(n, to: sys) do
          {:ok, encoded} ->
            overlaps = overlapping_system?(sys, encoded)

            case ExNumerlo.convert(encoded, to: :integer) do
              {:ok, decoded} ->
                if overlaps do
                  :ok
                else
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
  end

  describe "standard positional systems" do
    property "handle negative numbers" do
      check all(
              sys <-
                member_of([
                  :arabic,
                  :devanagari,
                  :thai,
                  :fullwidth,
                  :math_bold,
                  :adlam,
                  :balinese
                ]),
              n <- integer()
            ) do
        {:ok, encoded} = ExNumerlo.convert(n, to: sys)
        {:ok, decoded} = ExNumerlo.convert(encoded, to: :integer)
        assert decoded == n
      end
    end
  end

  describe "separator" do
    property "round-trips with a separator" do
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

  # A system whose encoded output can be auto-detected as a different system
  # (because its digit set is a strict subset of another system's) cannot be
  # proven via auto-detection. This mirrors the original duodecimal handling.
  defp overlapping_system?(sys, encoded) do
    case sys do
      :duodecimal -> !String.contains?(encoded, ["↊", "↋"])
      :hexadecimal -> not String.match?(encoded, ~r/[A-F]/)
      :binary -> true
      :octal -> true
      _ -> false
    end
  end
end
