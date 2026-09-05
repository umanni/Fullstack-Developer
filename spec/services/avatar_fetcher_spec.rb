require "rails_helper"

RSpec.describe AvatarFetcher do
  let(:public_ip) { "93.184.216.34" }

  def allow_resolve(host, ip_or_ips)
    allow(Resolv).to receive(:getaddresses).with(host).and_return(Array(ip_or_ips))
  end

  describe "#fetch" do
    it "downloads and returns the image when the content type and size are allowed" do
      allow_resolve("example.com", public_ip)
      stub_request(:get, "http://example.com/avatar.png")
        .to_return(status: 200, body: "fake-image-bytes", headers: { "Content-Type" => "image/png" })

      result = described_class.new("http://example.com/avatar.png").fetch

      expect(result.content_type).to eq("image/png")
      expect(result.filename).to eq("avatar.png")
      expect(result.io.read).to eq("fake-image-bytes")
    end

    it "follows redirects" do
      allow_resolve("example.com", public_ip)
      allow_resolve("cdn.example.com", public_ip)
      stub_request(:get, "http://example.com/avatar.png")
        .to_return(status: 302, headers: { "Location" => "http://cdn.example.com/avatar.png" })
      stub_request(:get, "http://cdn.example.com/avatar.png")
        .to_return(status: 200, body: "redirected-bytes", headers: { "Content-Type" => "image/jpeg" })

      result = described_class.new("http://example.com/avatar.png").fetch

      expect(result.content_type).to eq("image/jpeg")
    end

    it "raises when there are too many redirects" do
      stub_const("AvatarFetcher::MAX_REDIRECTS", 1)
      allow_resolve("example.com", public_ip)
      stub_request(:get, "http://example.com/a").to_return(status: 302, headers: { "Location" => "http://example.com/b" })
      stub_request(:get, "http://example.com/b").to_return(status: 302, headers: { "Location" => "http://example.com/c" })

      expect { described_class.new("http://example.com/a").fetch }
        .to raise_error(AvatarFetcher::FetchError, /redirect/)
    end

    it "rejects non-http(s) schemes" do
      expect { described_class.new("file:///etc/passwd").fetch }
        .to raise_error(AvatarFetcher::FetchError, /invalid URL/)
    end

    it "rejects a host that cannot be resolved" do
      allow_resolve("nowhere.invalid", [])

      expect { described_class.new("http://nowhere.invalid/avatar.png").fetch }
        .to raise_error(AvatarFetcher::FetchError, /resolve/)
    end

    it "rejects URLs that resolve to a private address" do
      allow_resolve("internal.example.com", "10.0.0.5")

      expect { described_class.new("http://internal.example.com/avatar.png").fetch }
        .to raise_error(AvatarFetcher::FetchError, /disallowed address/)
    end

    it "rejects URLs that resolve to the loopback address" do
      allow_resolve("localhost.example.com", "127.0.0.1")

      expect { described_class.new("http://localhost.example.com/avatar.png").fetch }
        .to raise_error(AvatarFetcher::FetchError, /disallowed address/)
    end

    it "rejects URLs that resolve to a link-local / cloud metadata address" do
      allow_resolve("metadata.example.com", "169.254.169.254")

      expect { described_class.new("http://metadata.example.com/avatar.png").fetch }
        .to raise_error(AvatarFetcher::FetchError, /disallowed address/)
    end

    it "rejects a disallowed content type" do
      allow_resolve("example.com", public_ip)
      stub_request(:get, "http://example.com/not-an-image.html")
        .to_return(status: 200, body: "<html></html>", headers: { "Content-Type" => "text/html" })

      expect { described_class.new("http://example.com/not-an-image.html").fetch }
        .to raise_error(AvatarFetcher::FetchError, /unsupported content type/)
    end

    it "rejects a file that exceeds the maximum size" do
      stub_const("AvatarFetcher::MAX_BYTES", 10)
      allow_resolve("example.com", public_ip)
      stub_request(:get, "http://example.com/big.png")
        .to_return(status: 200, body: "x" * 20, headers: { "Content-Type" => "image/png" })

      expect { described_class.new("http://example.com/big.png").fetch }
        .to raise_error(AvatarFetcher::FetchError, /too large/)
    end

    it "rejects an unexpected (non-success, non-redirect) response" do
      allow_resolve("example.com", public_ip)
      stub_request(:get, "http://example.com/missing.png").to_return(status: 404)

      expect { described_class.new("http://example.com/missing.png").fetch }
        .to raise_error(AvatarFetcher::FetchError, /unexpected response/)
    end

    it "rejects a malformed URL" do
      expect { described_class.new("http://exa mple.com/x").fetch }
        .to raise_error(AvatarFetcher::FetchError, /invalid URL/)
    end
  end
end
