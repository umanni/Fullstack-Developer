require "net/http"

# Boots the production SSR bundle (what the inertia_ssr Puma plugin runs in Docker) for
# spec/system/server_side_rendering_spec.rb. The bundle listens on a fixed port, 13714, so only
# that one spec file may start it; parallel_tests runs each file in a single worker.
module SsrServer
  URL = URI(InertiaRails::Configuration::DEFAULT_SSR_URL)
  BOOT_TIMEOUT = 15
  LOG = Rails.root.join("log/ssr_test.log").to_s

  class << self
    def start
      return if @pid
      raise "Port #{URL.port} is taken; stop the other Inertia SSR server first." if healthy?

      build
      # The locale and time zone of the Docker image, whatever the machine running the specs uses.
      env = { "TZ" => "UTC", "LC_ALL" => "en_US.UTF-8" }
      @pid = Process.spawn(env, "node", InertiaRails.configuration.ssr_bundle, out: LOG, err: [ :child, :out ])
      wait_until_healthy
    end

    def stop
      return unless @pid

      Process.kill("TERM", @pid)
      Process.wait(@pid)
    rescue Errno::ESRCH, Errno::ECHILD
      nil
    ensure
      @pid = nil
    end

    private

    # Built for production, as assets:precompile does, which is what makes the bundle start
    # its own HTTP server instead of only exporting the render function.
    def build
      node_env = ENV["NODE_ENV"]
      ENV["NODE_ENV"] = "production"
      ViteRuby.commands.build("--ssr") || raise("The Vite SSR build failed, see the output above.")
    ensure
      ENV["NODE_ENV"] = node_env
    end

    def wait_until_healthy
      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + BOOT_TIMEOUT

      until healthy?
        if Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline
          raise "The SSR server didn't answer on #{URL} within #{BOOT_TIMEOUT}s, see #{LOG}"
        end

        sleep 0.1
      end
    end

    def healthy?
      Net::HTTP.get_response(URI.join(URL, "/health")).is_a?(Net::HTTPSuccess)
    rescue SystemCallError, IOError, Net::OpenTimeout, Net::ReadTimeout
      false
    end
  end
end

RSpec.configure do |config|
  config.after(:suite) { SsrServer.stop }
end
