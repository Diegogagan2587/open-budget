class AccountSwitchesController < ApplicationController
  skip_account_scoping

  def create
    account = Current.user.accounts.find_by(id: params[:account_id])

    unless account
      redirect_to accounts_path, alert: t("account_switches.alert_not_found")
      return
    end

    # Store account ID in session
    session[:current_account_id] = account.id
    Current.account = account

    redirect_back(fallback_location: root_path)
  end
end
