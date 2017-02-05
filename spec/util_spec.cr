require "./spec_helper"

describe Camo::Util do
  describe ".hex_decode" do
    it "decodes hex" do
      hex = "4e6f64656a732073757821"
      expected = "Nodejs sux!"

      Camo::Util.hex_decode(hex).should eq(expected)
      Camo::Util.hex_decode(hex).try(&.to_slice.hexstring).should eq(hex)
    end

    it "decodes hex" do
      hex = "cebae1bdb9cf83cebcceb5"
      expected = "κόσμε"

      Camo::Util.hex_decode(hex).should eq(expected)
      Camo::Util.hex_decode(hex).try(&.to_slice.hexstring).should eq(hex)
    end
  end
end
