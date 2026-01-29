class AccountsController < ApplicationController
  skip_account_scoping only: [ :index, :new, :create ]
  before_action :set_account, only: [ :show, :edit, :update, :destroy ]
  before_action :ensure_account_access, only: [ :show, :edit, :update, :destroy ]
  before_action :ensure_owner, only: [ :edit, :update, :destroy ]

  def index
    @accounts = Current.user.accounts
  end

  def show
    @members = @account.account_memberships.includes(:user)
  end

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(account_params)

    respond_to do |format|
      if @account.save
        # Create membership for current user as owner
        @account.account_memberships.create!(user: Current.user, role: "owner")
        format.html { redirect_to @account, notice: t("accounts.flash.created") }
        format.json { render :show, status: :created, location: @account }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to @account, notice: t("accounts.flash.updated") }
        format.json { render :show, status: :ok, location: @account }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @account.destroy!

    respond_to do |format|
      format.html { redirect_to accounts_path, status: :see_other, notice: t("accounts.flash.destroyed") }
      format.json { head :no_content }
    end
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def ensure_account_access
    unless Current.user.accounts.include?(@account)
      redirect_to accounts_path, alert: "You don't have access to this account."
    end
  end

  def ensure_owner
    unless @account.account_memberships.find_by(user: Current.user)&.owner?
      redirect_to @account, alert: t("accounts.alert_owners_only")
    end
  end

  def account_params
    params.expect(account: [ :name ])
  end
end
