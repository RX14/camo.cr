require "./src/camo"

config = Camo::Config.new from_env: true
Camo.new(config).run
