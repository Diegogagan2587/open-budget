class ApplicationController < ActionController::Base
  include Authentication
  include AccountScoping
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_locale

  private

  def set_locale
    locale = if Current.user&.locale.present? && I18n.available_locales.map(&:to_s).include?(Current.user.locale)
      Current.user.locale
    elsif session[:locale].present? && I18n.available_locales.map(&:to_s).include?(session[:locale].to_s)
      session[:locale].to_s
    else
      I18n.default_locale
    end
    I18n.locale = locale.to_sym
  end

  def current_account_scope
    Current.account
  end
end
