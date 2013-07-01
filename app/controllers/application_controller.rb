class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include Jpmobile::ViewSelector

  before_action :set_locale
  before_action :disable_mobile_view!, if: :tablet?

  helper_method :tablet?

  # Set locale in response to client's browser setting.
  def set_locale
    accept_language = request.headers['Accept-Language']
    return if accept_language.blank?

    available = %w{en ja}
    accept_language.split(',').each do |locale_set|
      locale = locale_set.split(';').first
      if available.include?(locale)
        I18n.locale = locale
        break
      end
    end
  end

  def tablet?
    request.mobile && request.mobile.tablet?
  end
end
