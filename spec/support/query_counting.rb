# Counting the queries a request makes turns "this page does not have an N+1"
# into something the suite can hold to, rather than a claim in a README.
module QueryCounting
  IGNORED = /\ASCHEMA\z|\ATRANSACTION\z|\ACACHE\z/

  def count_queries
    queries = []
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |*, payload|
      queries << payload[:sql] unless payload[:name].to_s.match?(IGNORED)
    end

    yield

    queries
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end
end

RSpec.configure do |config|
  config.include QueryCounting, type: :request
end
