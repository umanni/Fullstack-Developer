module ApplicationHelper
  def page_title(title)
    content_for(:title) { "#{title} · Umanni Users" }
  end

  def flash_class(type)
    case type.to_sym
    when :notice then "border-emerald-200 bg-emerald-50 text-emerald-900"
    when :alert then "border-rose-200 bg-rose-50 text-rose-900"
    else "border-slate-200 bg-slate-50 text-slate-900"
    end
  end

  def role_badge_class(role)
    role.to_s == "admin" ? "bg-teal-100 text-teal-800" : "bg-slate-100 text-slate-700"
  end

  # Segmented Member | Admin control. Active segment is static; the other submits a toggle.
  def role_switch_for(user)
    content_tag :div,
                class: "inline-flex rounded-lg border border-slate-200 bg-slate-100 p-0.5 text-xs font-semibold",
                role: "group",
                "aria-label": "Role for #{user.full_name}" do
      safe_join([
        role_switch_segment(user, role: "member", label: "Member", active: user.member?),
        role_switch_segment(user, role: "admin", label: "Admin", active: user.admin?)
      ])
    end
  end

  def avatar_tag(user, size: 40, classes: "")
    wrapper_classes = "inline-flex shrink-0 overflow-hidden rounded-full bg-slate-200 #{classes}"
    wrapper_style = "width: #{size}px; height: #{size}px; min-width: #{size}px; min-height: #{size}px;"

    content_tag :span, class: wrapper_classes, style: wrapper_style do
      if user.avatar_image.attached?
        image_tag avatar_image_source(user, size),
                  class: "h-full w-full object-cover",
                  width: size,
                  height: size,
                  alt: user.full_name
      elsif user.avatar_url.present?
        image_tag user.avatar_url,
                  class: "h-full w-full object-cover",
                  width: size,
                  height: size,
                  alt: user.full_name,
                  loading: "lazy",
                  referrerpolicy: "no-referrer"
      else
        content_tag :span,
                    user.initials,
                    class: "flex h-full w-full items-center justify-center bg-slate-800 text-white text-sm font-semibold",
                    aria: { label: user.full_name }
      end
    end
  end

  def import_status_class(status)
    {
      "pending" => "bg-amber-100 text-amber-800",
      "processing" => "bg-sky-100 text-sky-800",
      "completed" => "bg-emerald-100 text-emerald-800",
      "failed" => "bg-rose-100 text-rose-800"
    }[status.to_s] || "bg-slate-100 text-slate-700"
  end

  private

  def role_switch_segment(user, role:, label:, active:)
    if active
      content_tag :span,
                  label,
                  class: "rounded-md px-2.5 py-1 #{role == "admin" ? "bg-teal-700 text-white shadow-sm" : "bg-white text-slate-900 shadow-sm"}"
    elsif user == current_user
      content_tag :span,
                  label,
                  class: "rounded-md px-2.5 py-1 text-slate-400",
                  title: "You cannot change your own role"
    else
      button_to label,
                toggle_role_admin_user_path(user),
                method: :patch,
                class: "rounded-md px-2.5 py-1 text-slate-600 transition hover:bg-white hover:text-slate-900"
    end
  end

  def avatar_image_source(user, size)
    user.avatar_image.variant(resize_to_fill: [ size * 2, size * 2 ])
  rescue StandardError
    user.avatar_image
  end
end
