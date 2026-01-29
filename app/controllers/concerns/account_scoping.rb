module AccountScoping
  extend ActiveSupport::Concern

  included do
    before_action :ensure_account_set, if: -> { Current.user.present? }
  end

  class_methods do
    def skip_account_scoping(**options)
      skip_before_action :ensure_account_set, **options
    end
  end

  private

  def ensure_account_set
    return unless Current.user

    if !Current.account && !skip_account_scoping?
      redirect_to accounts_path, alert: t("account_scoping.select_account")
    end
  end

  def skip_account_scoping?
    # Allow account switching and account management without account set
    controller_name.in?(%w[account_switches accounts settings]) || action_name == "create" && controller_name == "account_switches"
  end
end
