require "http"
require "json"

class Camo
  VERSION = "0.1.0"

  KiB = 1024
  MiB = 1024 * KiB
  GiB = 1024 * MiB

  # NOTE: use Atomic after parallelism
  @total_requests = 0
  @processing_requests = 0

  @start_date = Time.now

  def initialize(@config : Config)
  end

  def run
    p @config if @config.debug

    server = HTTP::Server.new("0.0.0.0", @config.port) do |context|
      @total_requests += 1
      @processing_requests += 1

      trace = Trace.new
      time_start = Time.now

      begin
        trace.raw_request_url = context.request.resource
        trace.request_headers = context.request.headers
        trace.request_version = context.request.version

        add_security_headers(context.response)

        unless context.request.method == "GET"
          message = trace.response_reason = "No #{context.request.method} resources"
          context.response.puts message
          context.response.status_code = 400
          next
        end

        if context.request.headers["Via"]?.try(&.includes?(@config.user_agent))
          message = trace.response_reason = "Request loop detected"
          context.response.puts message
          context.response.status_code = 400
          next
        end

        case context.request.path
        when "/favicon.ico"
          context.response.status_code = 204
        when "/status", "/"
          context.response.headers["Cache-Control"] = "no-cache, no-store, private, must-revalidate"
          context.response.headers["Expires"] = "0"
          context.response.puts "ok #{@processing_requests}/#{@total_requests} since #{@start_date}"
        else
          Request.new(context, @config, trace).process
        end
      ensure
        @processing_requests -= 1

        begin
          # Don't cache errors
          unless 200 <= context.response.status_code <= 299
            context.response.headers["Cache-Control"] = "no-cache, no-store, private, must-revalidate"
          end

          trace.response_status_code = context.response.status_code
          trace.response_headers = context.response.headers
          trace.response_time = Time.now - time_start
        ensure
          if @config.debug
            time_start_str = Time::Format::ISO_8601_DATE_TIME.format(time_start)

            puts
            puts "-----#{time_start_str}-----"
            p trace
            puts "----------------------------------"
          end
        end
      end
    end

    puts "Camo.cr running on http://localhost:#{@config.port}"
    server.listen
  end

  private def add_security_headers(response)
    response.headers["X-Frame-Options"] = "deny"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["Content-Security-Policy"] = "default-src 'none'; img-src data:; style-src 'unsafe-inline'"
    response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
  end
end

require "./camo/*"
