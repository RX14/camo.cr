require "../src/camo"
require "secure_random"

camo_key = "0x24FEEDFACEDEADBEEFCAFE"
config = Camo::Config.new(camo_key)

spawn { Camo.new(config).run }

Process.run(
  "rake", args: ["bundle", "test"],
  env: {"CAMO_KEY" => camo_key},
  output: true, error: true,
  chdir: File.join(__DIR__, "upstream")
)
