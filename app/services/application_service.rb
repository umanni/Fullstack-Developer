# Base service class following Command pattern
class ApplicationService
  class << self
    # Call the service with given arguments
    def call(*args, **kwargs)
      new(*args, **kwargs).call
    end
  end

  # Override in subclasses
  def call
    raise NotImplementedError, "Subclasses must implement the call method"
  end

  private

  # Success result
  def success(data = nil)
    ServiceResult.new(success: true, data: data)
  end

  # Error result
  def failure(errors)
    ServiceResult.new(success: false, errors: errors)
  end
end

# Service result object
class ServiceResult
  attr_reader :data, :errors

  def initialize(success:, data: nil, errors: nil)
    @success = success
    @data = data
    @errors = errors || []
  end

  def success?
    @success
  end

  def failure?
    !@success
  end

  def error_messages
    return [] if errors.blank?

    case errors
    when String
      [ errors ]
    when Array
      errors
    when ActiveModel::Errors
      errors.full_messages
    else
      [ errors.to_s ]
    end
  end
end
