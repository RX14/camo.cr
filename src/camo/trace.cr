class Camo::Trace
  property raw_request_url : String?
  property request_headers : HTTP::Headers?
  property request_version : String?

  property response_status_code : Int32?
  property response_headers : HTTP::Headers?
  property response_reason : String?
  property response_time : Time::Span?

  property provided_digest : String?
  property expected_digest : String?
  property provided_url : String?

  property intermediate_requests = Array(RequestTrace).new

  class RequestTrace
    property url : String?
    property request_headers : HTTP::Headers?

    property response_headers : HTTP::Headers?
    property response_status_code : Int32?
    property response_time : Time::Span?
  end
end
