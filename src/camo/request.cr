require "http"
require "openssl/hmac"

struct Camo::Request
  def initialize(context, @config : Config, @trace : Trace)
    @request = context.request
    @response = context.response
  end

  @request : HTTP::Request
  @response : HTTP::Server::Response

  def process
    # First, we parse URL and digest from URL
    digest, dest_url = parse_url || return

    # Then we check that the digest matches
    expected_digest = @trace.expected_digest = OpenSSL::HMAC.hexdigest(:sha1, @config.key, dest_url)
    unless digest == expected_digest
      message = <<-RES
        Checksum mismatch:
        Got:      #{digest}
        Expected: #{expected_digest}
        RES
      return error(400, message)
    end

    # Finally, we perform the HTTP request
    begin
      proxy_request(URI.parse(dest_url))
    rescue ex
      error(500, ex.message)
    end
  end

  private def proxy_request(dest_url, *, redirects = @config.max_redirects)
    request_trace = Trace::RequestTrace.new
    @trace.intermediate_requests << request_trace
    request_trace.url = dest_url.to_s

    return error(500, "Exceeded max redirects") if redirects < 0

    headers = request_trace.request_headers = HTTP::Headers{
      "Via"        => @config.user_agent,
      "User-Agent" => @config.user_agent,
      "Accept"     => @request.headers["Accept"]? || "image/*",
    }

    new_url = nil
    HTTP::Client.new(dest_url) do |client|
      client.connect_timeout = @config.socket_timeout
      client.dns_timeout = @config.socket_timeout
      client.read_timeout = @config.socket_timeout

      time_start = Time.now
      client.get(dest_url.full_path, headers) do |upstream_response|
        request_trace.response_time = Time.now - time_start
        request_trace.response_headers = upstream_response.headers
        request_trace.response_status_code = upstream_response.status_code

        case upstream_response.status_code
        when 301, 302, 303, 307
          new_url = URI.parse(upstream_response.headers["Location"])
          new_url.host = dest_url.host unless new_url.host
          new_url.scheme = dest_url.scheme unless new_url.scheme
          new_url.port = dest_url.port unless new_url.port
        else
          proxy_response(upstream_response)
        end
      end
    end

    # Bounce outside HTTP::Client block so we don't hold old
    # connections open while redirecting.
    if new_url
      proxy_request(new_url, redirects: redirects - 1)
    end
  end

  private def proxy_response(upstream_response)
    @response.status_code = upstream_response.status_code

    content_length = upstream_response.headers["Content-Length"]?.try(&.to_i?) || 0
    return error(500, "Content-Length limit exceeded") if content_length > @config.length_limit

    content_type = upstream_response.headers["Content-Type"]?
    return error(500, "No Content-Type returned") unless content_type

    content_type_prefix = content_type.split(';', 2)[0].downcase
    return error(500, "Non-image Content-Type returned: #{content_type_prefix}") unless @config.accepted_mime_types.includes? content_type_prefix

    copy_header "Content-Type"
    copy_header "Cache-Control"
    copy_header "ETag"
    copy_header "Expires"
    copy_header "Last-Modified"
    copy_header "Content-Length"

    @response.headers["Cache-Control"] ||= "public, max-age=31536000"
    @response.headers["Camo-Host"] = @config.hostname

    if timing_allow_origin = @config.timing_allow_origin
      @response.headers["Timing-Allow-Origin"] = timing_allow_origin
    end

    IO.copy(upstream_response.body_io, @response, @config.length_limit)
  end

  private macro copy_header(name)
    if %header = upstream_response.headers[{{name}}]?
      @response.headers[{{name}}] = %header
    end
  end

  private def parse_url
    path_parts = @request.path.chomp('/').lchop('/').split('/', 2)

    case path_parts.size
    when 1
      digest = @trace.provided_digest = path_parts[0]
      dest_url = @trace.provided_url = @request.query_params["url"]?

      return error(400, "No url query parameter set") unless dest_url
    when 2
      digest = @trace.provided_digest = path_parts[0]
      dest_url = @trace.provided_url = Util.hex_decode(path_parts[1])

      return error(400, "Image url was not valid hex (#{path_parts[1]})") unless dest_url
    else
      raise "Impossible path_parts size"
    end

    {digest, dest_url}
  end

  private def error(status_code, message)
    @trace.response_reason = message
    dest_url = parse_url.try { |t| t[1] }
    @response.puts("#{dest_url}: #{message}")
    @response.status_code = status_code

    nil
  end
end
