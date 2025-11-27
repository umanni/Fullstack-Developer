# ActionCable test helpers
RSpec.configure do |config|
  # Configure ActionCable test adapter
  config.before(:each, type: :channel) do
    ActionCable.server.config.cable = { adapter: 'test' }
  end
end

