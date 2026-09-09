# Chooses the locale for every request, in a deliberate order of preference:
# the signed-in user's saved choice, then a visitor's session choice, then what
# the browser asks for, then the default.
module Localization
  extend ActiveSupport::Concern

  included do
    around_action :switch_locale
    helper_method :current_locale, :supported_locales
  end

  private

  def switch_locale(&)
    I18n.with_locale(current_locale, &)
  end

  def current_locale
    @current_locale ||= Current.user&.locale.presence ||
                        session[:locale].presence ||
                        locale_from_request_headers ||
                        I18n.default_locale.to_s
  end

  def supported_locales
    User::SUPPORTED_LOCALES
  end

  # Reads Accept-Language and takes the first entry the application actually
  # speaks, preferring an exact tag ("pt-BR") over a language match ("pt").
  # Quality weights are ignored: browsers already send the list in descending
  # order, and parsing them would add work for no difference here.
  def locale_from_request_headers
    tags = accepted_language_tags

    tags.find { |tag| User::SUPPORTED_LOCALES.include?(tag) } ||
      tags.filter_map { |tag| supported_locale_for_language(tag) }.first
  end

  def accepted_language_tags
    request.headers["Accept-Language"].to_s.split(",").map { |tag| tag.split(";").first.to_s.strip }
  end

  def supported_locale_for_language(tag)
    language = tag.split("-").first
    User::SUPPORTED_LOCALES.find { |locale| locale.split("-").first == language }
  end
end
