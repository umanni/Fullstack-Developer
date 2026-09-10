# frozen_string_literal: true

# Release It! — lightweight request metrics for production observability.
# Captures request rate, latency, error rate, and queue depth signals.
# Integrates with ActiveSupport::Notifications for zero-config Rails instrumentation.

# Instrument ActionController for request metrics
ActiveSupport::Notifications.subscribe("process_action.action_controller") do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  payload = event.payload

  status = payload[:status]
  controller = payload[:controller]
  action = payload[:action]
  duration_ms = event.duration.round(2)

  # Log slow requests (> 500ms)
  if duration_ms > 500
    Rails.logger.warn(
      "[Metrics] SLOW request #{controller}##{action} " \
      "status=#{status} duration=#{duration_ms}ms"
    )
  end

  # Log errors
  if status && status >= 500
    Rails.logger.error(
      "[Metrics] ERROR request #{controller}##{action} " \
      "status=#{status} duration=#{duration_ms}ms"
    )
  end
end

# Instrument job execution for queue depth signals
ActiveSupport::Notifications.subscribe("perform_start.active_job") do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  job_name = event.payload[:job].class.name
  Rails.logger.info("[Metrics] job_start job=#{job_name}")
end

ActiveSupport::Notifications.subscribe("perform.active_job") do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  job_name = event.payload[:job].class.name
  duration_ms = event.duration.round(2)
  error = event.payload[:error_object]

  if error
    Rails.logger.error(
      "[Metrics] job_fail job=#{job_name} duration=#{duration_ms}ms " \
      "error=#{error.class}: #{error.message}"
    )
  else
    Rails.logger.info(
      "[Metrics] job_complete job=#{job_name} duration=#{duration_ms}ms"
    )
  end
end
