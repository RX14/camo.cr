module Camo::Util
  extend self

  def hex_decode(hex)
    return unless hex.size % 2 == 0

    String.new(hex.size / 2) do |buffer|
      0.step(to: hex.size - 1, by: 2) do |i|
        high_nibble = hex.to_unsafe[i].unsafe_chr.to_u8?(16)
        low_nibble = hex.to_unsafe[i + 1].unsafe_chr.to_u8?(16)
        return unless high_nibble && low_nibble

        buffer[i / 2] = (high_nibble << 4) | low_nibble
      end

      {hex.size / 2, 0}
    end
  end
end
