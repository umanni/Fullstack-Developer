# Jobs are enqueued rather than executed by default, so specs can assert on
# what was scheduled. Tag an example with `perform_enqueued: true` when the
# work itself is what is under test.
RSpec.configure do |config|
  config.before do |example|
    ActiveJob::Base.queue_adapter =
      example.metadata[:perform_enqueued] ? :inline : :test
  end
end
