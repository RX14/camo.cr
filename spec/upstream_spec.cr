require "../src/camo"

describe Camo do
  it "runs upstream tests" do
    camo_key = "0x24FEEDFACEDEADBEEFCAFE"
    config = Camo::Config.new(camo_key)

    spawn { Camo.new(config).run }

    Process.run(
      "rake", args: ["bundle", "test"],
      env: {"CAMO_KEY" => camo_key},
      output: Process::Redirect::Inherit, error: Process::Redirect::Inherit,
      chdir: File.join(__DIR__, "upstream")
    )
  end
end
