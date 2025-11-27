# frozen_string_literal: true

Rails.application.config.active_storage.variant_processor = :mini_magick

# Configure Active Storage service based on environment
# This must be set before models with Active Storage attachments are loaded
Rails.application.config.active_storage.service = 
  case Rails.env.to_s
  when 'development'
    :local
  when 'test'
    :test
  when 'production'
    :local
  else
    :local
  end

