# The test environment runs on :null_store, which retains nothing and reports
# every write as a success. Anything built on the cache is invisible under it --
# a `fetch` never hits, and an `unless_exist` claim always looks unclaimed -- so
# specs exercising cache behaviour itself swap in a real store for the duration.
RSpec.shared_context "with a real cache store" do
  around do |example|
    original = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    example.run
  ensure
    Rails.cache = original
  end
end

RSpec.configure do |config|
  config.include_context "with a real cache store", :cache
end
