module ApplicationHelper
  # Falls back to initials when there is no avatar to show. Two letters at most,
  # taken from the first and last word of the name.
  def user_initials(user)
    parts = user.full_name.to_s.split.compact_blank
    return "?" if parts.empty?

    [parts.first, (parts.last if parts.size > 1)].compact.pluck(0).join
  end

  # One place decides how an avatar is rendered, so the precedence between an
  # upload, a remote URL and initials is not re-decided in every template.
  #
  # The remote URL is never fetched by the server -- it is handed to the browser
  # as an img src, with the referrer withheld so the other site learns nothing
  # about who is looking.
  def avatar_tag(user, size:, classes: nil)
    dimensions = { class: "avatar #{classes}".strip, style: "width: #{size}px; height: #{size}px;" }

    case user.avatar_source
    when :attachment
      image_tag user.avatar.variant(resize_to_fill: [size * 2, size * 2]),
                alt: "", loading: "lazy", **dimensions
    when :remote
      image_tag user.displayable_avatar_url, alt: "", loading: "lazy",
                                             referrerpolicy: "no-referrer", **dimensions
    else
      style = "#{dimensions[:style]} font-size: #{[size / 3, 10].max}px;"
      tag.span user_initials(user), aria: { hidden: true }, **dimensions.merge(style: style)
    end
  end

  # An audit row's details are a small JSON object -- which columns changed, or
  # which import a row came from. Rendered as a sentence rather than as JSON,
  # and never showing the old and new values of anything sensitive.
  def audit_event_details(event)
    return t("admin.audit_events.details_import", id: event.details["user_import_id"]) if event.imported?

    changed = event.details.keys.map { |name| User.human_attribute_name(name) }
    return "—" if changed.empty?

    changed.to_sentence
  end

  def role_badge(user)
    tag.span t("roles.#{user.role}"),
             class: "badge #{user.admin? ? "badge-admin" : "badge-user"}"
  end
end
