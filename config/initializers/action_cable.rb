# frozen_string_literal: true

# ActionCable will be eager loaded in production, so it's recommended to set
# the adapter here instead of in config/cable.yml
Rails.application.config.action_cable.url = '/cable'
Rails.application.config.action_cable.allowed_request_origins = [/http:\/\/*/, /https:\/\/*/]

