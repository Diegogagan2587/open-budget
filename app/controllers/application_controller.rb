class ApplicationController < ActionController::Base
  include Authentication
  include AccountScoping
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def current_account_scope
    Current.account
  end
end
