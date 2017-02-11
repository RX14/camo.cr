class Camo::Config
  getter port = 8081
  getter key : String
  getter hostname = "unknown"
  getter user_agent = "Camo.cr Asset Proxy #{VERSION}"
  getter length_limit : Int32 = 5 * MiB
  getter socket_timeout : Time::Span = 10.seconds
  getter max_redirects = 4
  getter keep_alive = false
  getter timing_allow_origin : String?
  getter debug = false
  getter accepted_mime_types : Array(String)

  def initialize(@key)
    @accepted_mime_types = default_accepted_mime_types
  end

  def initialize(*, from_env : Bool)
    if port = ENV["PORT"]?
      port = port.to_i?
      raise Error.new("ENV[\"PORT\"] was not an integer") unless port
      @port = port
    end

    key = ENV["CAMO_KEY"]?
    raise Error.new("ENV[\"CAMO_KEY\"] was not set") unless key
    @key = key

    if hostname = ENV["CAMO_HOSTNAME"]?
      @hostname = hostname
    end

    if user_agent = ENV["CAMO_HEADER_VIA"]?
      @user_agent = user_agent
    end

    if length_limit = ENV["CAMO_LENGTH_LIMIT"]?
      length_limit = length_limit.to_i?
      raise Error.new("ENV[\"CAMO_LENGTH_LIMIT\"] was not an integer") unless length_limit
      @length_limit = length_limit
    end

    if socket_timeout_seconds = ENV["CAMO_SOCKET_TIMEOUT"]?
      socket_timeout_seconds = socket_timeout_seconds.to_f?
      raise Error.new("ENV[\"CAMO_SOCKET_TIMEOUT\"] was not a number") unless socket_timeout_seconds
      @socket_timeout = socket_timeout_seconds.seconds
    end

    if max_redirects = ENV["CAMO_MAX_REDIRECTS"]?
      max_redirects = max_redirects.to_i?
      raise Error.new("ENV[\"CAMO_MAX_REDIRECTS\"] was not an integer") unless max_redirects
      @max_redirects = max_redirects
    end

    if keep_alive = ENV["CAMO_KEEP_ALIVE"]?
      case keep_alive.downcase
      when "true"
        raise Error.new("CAMO_KEEP_ALIVE=true is not supported yet")
        @keep_alive = true
      when "false"
        @keep_alive = false
      else
        raise Error.new("ENV[\"CAMO_KEEP_ALIVE\"] must either be true or false")
      end
    end

    if timing_allow_origin = ENV["CAMO_TIMING_ALLOW_ORIGIN"]?
      @timing_allow_origin = timing_allow_origin
    end

    if debug = ENV["CAMO_LOGGING_ENABLED"]?
      case debug.downcase
      when "debug"
        @debug = true
      when "disabled"
        @debug = false
      else
        raise Error.new("ENV[\"CAMO_LOGGING_ENABLED\"] must either be 'debug' or 'disabled'")
      end
    end

    if mime_types_file = ENV["CAMO_MIME_TYPES"]?
      if File.exists?(mime_types_file)
        @accepted_mime_types = Array(String).from_json(File.read(mime_types_file))
      else
        raise Error.new("ENV[\"CAMO_MIME_TYPES\"] should point to a JSON file with the list of mime-types")
      end
    else
      # default to built-in mime-types list
      @accepted_mime_types = default_accepted_mime_types
    end
  end

  def default_accepted_mime_types
    Array(String).from_json({{ `cat "#{__DIR__}/mime-types.json"`.stringify }})
  end

  class Error < Exception
  end
end
