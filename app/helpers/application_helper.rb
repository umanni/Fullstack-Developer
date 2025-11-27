module ApplicationHelper
  def avatar_image_tag(user, options = {})
    options[:class] ||= 'avatar-small'
    options[:alt] ||= user.full_name
    options[:class] = "#{options[:class]} avatar-placeholder" unless user.avatar_image.attached? || user.avatar_url.present?

    if user.avatar_image.attached?
      image_tag(user.avatar_image, options)
    elsif user.avatar_url.present?
      image_tag(user.avatar_url, options.merge(onerror: "this.onerror=null; this.classList.add('avatar-placeholder'); this.style.backgroundColor='#e9ecef';"))
    else
      content_tag(:div, '', class: "#{options[:class]} avatar-placeholder", style: 'background-color: #e9ecef; display: inline-block;')
    end
  end

  def flash_class(level)
    case level.to_sym
    when :notice then 'alert-success'
    when :alert then 'alert-danger'
    when :error then 'alert-danger'
    when :warning then 'alert-warning'
    when :info then 'alert-info'
    else 'alert-info'
    end
  end
end

