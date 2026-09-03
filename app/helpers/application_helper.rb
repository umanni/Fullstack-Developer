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

  def avatar_tag(user, size: 40, classes: "")
    dimension = "w-[#{size}px] h-[#{size}px]"
    if user.avatar_image.attached?
      image_tag avatar_image_source(user, size),
                class: "#{dimension} rounded-full object-cover #{classes}",
                alt: user.full_name
    elsif user.avatar_url.present?
      image_tag user.avatar_url,
                class: "#{dimension} rounded-full object-cover #{classes}",
                alt: user.full_name,
                loading: "lazy",
                referrerpolicy: "no-referrer"
    else
      content_tag :span,
                  user.initials,
                  class: "#{dimension} inline-flex items-center justify-center rounded-full bg-slate-800 text-white text-sm font-semibold #{classes}",
                  aria: { label: user.full_name }
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

  def avatar_image_source(user, size)
    user.avatar_image.variant(resize_to_fill: [ size * 2, size * 2 ])
  rescue StandardError
    user.avatar_image
  end
end
