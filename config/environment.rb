# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

BroadcastDashboardDataJob.perform_later
BroadcastUserBulksDataJob.perform_later