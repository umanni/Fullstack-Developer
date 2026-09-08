# frozen_string_literal: true

module DashboardChannel
  class Channel < ApplicationCable::Channel
    def subscribed
      return reject unless Users::Policy.admin_reader?(current_user)

      stream_from "dashboard_stats"
    end
  end
end
