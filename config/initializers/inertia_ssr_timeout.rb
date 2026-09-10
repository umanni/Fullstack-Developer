# frozen_string_literal: true

# OptimizationRef: RB4-RM80-InertiaReact

# Bound the Inertia SSR render request. The gem's renderer uses Net::HTTP
# with 60s default timeouts; a hung SSR server would stall web requests
# for up to ~120s before falling back to client-side rendering. This
# bounds the wait to 5 seconds; Net::OpenTimeout/Net::ReadTimeout are
# StandardError subclasses, so the gem's existing error handler catches
# them and degrades to client-side rendering.
Rails.application.config.after_initialize do
  InertiaRails::SSRRenderer.prepend(Module.new do
    def request
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = 5
      http.read_timeout = 5
      response = http.post(uri.request_uri, page_json, "Content-Type" => "application/json")

      unless response.is_a?(Net::HTTPSuccess)
        body = begin
          JSON.parse(response.body)
        rescue JSON::ParserError
          {}
        end
        body["error"] ||= "SSR server returned #{response.code}"
        raise InertiaRails::SSRError.from_response(body)
      end

      JSON.parse(response.body)
    end
  end)
end
