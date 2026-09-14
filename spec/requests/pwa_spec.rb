require "rails_helper"

RSpec.describe "Phone and home-screen support", type: :request do
  def png_size(src)
    path = Rails.public_path.join(src.delete_prefix("/"))
    File.binread(path, 8, 16).unpack("NN").join("x")
  end

  describe "GET /manifest.json" do
    let(:manifest) do
      get pwa_manifest_path(format: :json)
      JSON.parse(response.body)
    end

    it "describes the app so it can open standalone from the home screen" do
      expect(manifest).to include(
        "name" => "Umanni", "short_name" => "Umanni", "start_url" => "/",
        "display" => "standalone", "theme_color" => "#ffffff"
      )
    end

    it "lists the 192 and 512 pixel icons Android asks for, including a maskable one" do
      expect(manifest["icons"]).to include(
        a_hash_including("sizes" => "192x192"),
        a_hash_including("sizes" => "512x512", "purpose" => "maskable")
      )
    end

    it "points only at icon files that exist at the size they claim" do
      manifest["icons"].each do |icon|
        expect(png_size(icon["src"])).to eq(icon["sizes"])
      end
    end

    it "is served to visitors who are not signed in" do
      get pwa_manifest_path(format: :json)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "the page head" do
    let(:head) do
      get new_session_path
      Nokogiri::HTML(response.body)
    end

    it "declares the page language for screen readers" do
      expect(head.at_css("html")["lang"]).to eq("en")
    end

    it "sizes to the device and reaches under the notch" do
      expect(head.at_css("meta[name=viewport]")["content"])
        .to eq("width=device-width,initial-scale=1,viewport-fit=cover")
    end

    it "links the manifest" do
      expect(head.at_css("link[rel=manifest]")["href"]).to eq(pwa_manifest_path(format: :json))
    end

    it "gives iOS a 180 pixel home-screen icon and a title" do
      expect(png_size(head.at_css("link[rel=apple-touch-icon]")["href"])).to eq("180x180")
      expect(head.at_css("meta[name=apple-mobile-web-app-title]")["content"]).to eq("Umanni")
      expect(head.at_css("meta[name=apple-mobile-web-app-capable]")["content"]).to eq("yes")
    end

    it "tints the browser bar to match the header" do
      expect(head.at_css("meta[name=theme-color]")["content"]).to eq("#ffffff")
    end
  end

  describe "which phone browsers get in" do
    def visit_with(user_agent) = get(new_session_path, headers: { "User-Agent" => user_agent })

    it "lets in Safari on iOS 16.4, the oldest that renders the stylesheet" do
      visit_with "Mozilla/5.0 (iPhone; CPU iPhone OS 16_4 like Mac OS X) AppleWebKit/605.1.15 " \
                 "(KHTML, like Gecko) Version/16.4 Mobile/15E148 Safari/604.1"

      expect(response).to have_http_status(:ok)
    end

    it "lets in Chrome 111 on Android" do
      visit_with "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 " \
                 "(KHTML, like Gecko) Chrome/111.0.0.0 Mobile Safari/537.36"

      expect(response).to have_http_status(:ok)
    end

    it "turns away Safari on iOS 15, which cannot render the stylesheet" do
      visit_with "Mozilla/5.0 (iPhone; CPU iPhone OS 15_6 like Mac OS X) AppleWebKit/605.1.15 " \
                 "(KHTML, like Gecko) Version/15.6 Mobile/15E148 Safari/604.1"

      expect(response).to have_http_status(:not_acceptable)
    end
  end
end
