# app/jobs/dashboard/broadcast_job.rb
module Dashboard
  class BroadcastJob < ApplicationJob
    queue_as :default

    def perform
      Dashboard::Stats.expire
      Dashboard::Broadcaster.broadcast
    end
  end
end
