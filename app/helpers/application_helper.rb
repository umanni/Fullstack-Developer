module ApplicationHelper
  # Falls back to initials when there is no avatar to show. Two letters at most,
  # taken from the first and last word of the name.
  def user_initials(user)
    parts = user.full_name.to_s.split.compact_blank
    return "?" if parts.empty?

    [parts.first, (parts.last if parts.size > 1)].compact.pluck(0).join
  end

  def role_badge(user)
    tag.span user.role.humanize,
             class: "badge #{user.admin? ? "badge-admin" : "badge-user"}"
  end
end
