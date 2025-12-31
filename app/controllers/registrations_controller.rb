class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_registration_url, alert: "Try again later." }

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      # Create a default account for the new user
      account = Account.create!(name: "#{@user.name}'s Account")
      account.account_memberships.create!(user: @user, role: "owner")

      start_new_session_for @user
      session[:current_account_id] = account.id
      flash[:notice] = "Account created successfully! Welcome!"
      redirect_to after_authentication_url
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
    end
end
