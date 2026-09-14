module ApplicationHelper
  IMPORT_STATUS_BADGES = {
    "pending" => "badge-neutral", "processing" => "badge-info",
    "completed" => "badge-success", "failed" => "badge-danger"
  }.freeze

  def import_status_badge(spreadsheet_import)
    IMPORT_STATUS_BADGES.fetch(spreadsheet_import.status, "badge-neutral")
  end

  def field_error(model, attribute)
    messages = model.errors.full_messages_for(attribute)
    return if messages.empty?

    tag.p messages.to_sentence, class: "field-error", id: "#{attribute}_error"
  end

  def field_error_attributes(model, attribute)
    return {} if model.errors[attribute].empty?

    { aria: { invalid: true, describedby: "#{attribute}_error" } }
  end
end
