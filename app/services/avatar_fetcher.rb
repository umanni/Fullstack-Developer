require "net/http"
require "resolv"
require "ipaddr"

# Downloads a remote image over HTTP(S) to be attached as a User's avatar.
#
# Hardened against SSRF: only plain http(s) URLs are accepted, the resolved
# IP address must be public (no loopback/private/link-local ranges), redirects
# are capped, and the response body is streamed with an early size cutoff so a
# malicious server cannot exhaust memory before we notice it is too large.
class AvatarFetcher
  class FetchError < StandardError; end

  ALLOWED_CONTENT_TYPES = %w[image/png image/jpeg image/webp].freeze
  MAX_BYTES = 5.megabytes
  MAX_REDIRECTS = 3
  OPEN_TIMEOUT = 5
  READ_TIMEOUT = 10

  Result = Data.define(:io, :content_type, :filename)

  def initialize(url)
    @url = url
  end

  def fetch
    uri = parse_http_uri!(@url)

    MAX_REDIRECTS.downto(0) do |redirects_left|
      guard_against_ssrf!(uri)

      outcome = request_once(uri)
      return outcome.fetch(:success) if outcome.key?(:success)

      raise FetchError, "too many redirects" if redirects_left.zero?
      uri = parse_http_uri!(outcome.fetch(:redirect))
    end
  end

  private

  def parse_http_uri!(url)
    uri = URI.parse(url)
    raise FetchError, "invalid URL" unless uri.is_a?(URI::HTTP) && uri.host.present?
    uri
  rescue URI::InvalidURIError
    raise FetchError, "invalid URL"
  end

  def guard_against_ssrf!(uri)
    addresses = Resolv.getaddresses(uri.host)
    raise FetchError, "could not resolve host" if addresses.empty?

    addresses.each do |address|
      ip = IPAddr.new(address)
      if ip.private? || ip.loopback? || ip.link_local?
        raise FetchError, "URL resolves to a disallowed address"
      end
    end
  end

  def request_once(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = OPEN_TIMEOUT
    http.read_timeout = READ_TIMEOUT

    http.start do |client|
      client.request_get(uri) do |response|
        return { redirect: response["location"] } if response.is_a?(Net::HTTPRedirection)

        unless response.is_a?(Net::HTTPSuccess)
          raise FetchError, "unexpected response #{response.code}"
        end

        content_type = response.content_type
        unless ALLOWED_CONTENT_TYPES.include?(content_type)
          raise FetchError, "unsupported content type #{content_type.inspect}"
        end

        buffer = +""
        response.read_body do |chunk|
          buffer << chunk
          raise FetchError, "file too large" if buffer.bytesize > MAX_BYTES
        end

        return { success: Result.new(io: StringIO.new(buffer), content_type: content_type, filename: filename_for(uri)) }
      end
    end
  end

  def filename_for(uri)
    name = File.basename(uri.path.to_s)
    name.presence || "avatar"
  end
end
