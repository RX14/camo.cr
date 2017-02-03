require "./spec_helper"
require "yaml"

describe Camo do
  describe "VERSION" do
    it "matches shards.yml" do
      version = YAML.parse(File.read(File.join(__DIR__, "..", "shard.yml")))["version"].as_s
      version.should eq(Camo::VERSION)
    end
  end
end
