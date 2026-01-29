class InventoryItemsController < ApplicationController
  before_action :set_inventory_item, only: [ :show, :edit, :update, :destroy, :add_to_shopping_list ]

  def index
    @stock_filter = params[:stock_state] || "all"
    @inventory_items = InventoryItem.for_account(Current.account)

    if @stock_filter != "all"
      @inventory_items = @inventory_items.where(stock_state: @stock_filter)
    end

    @inventory_items = @inventory_items.order(:name)
  end

  def show
  end

  def new
    @inventory_item = InventoryItem.new
    @categories = Category.for_account(Current.account).order(:name)
  end

  def create
    @inventory_item = InventoryItem.for_account(Current.account).new(inventory_item_params)
    @inventory_item.account = Current.account

    respond_to do |format|
      if @inventory_item.save
        format.html { redirect_to @inventory_item, notice: t("inventory_items.flash.created") }
        format.json { render :show, status: :created, location: @inventory_item }
      else
        @categories = Category.for_account(Current.account).order(:name)
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @inventory_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @categories = Category.for_account(Current.account).order(:name)
  end

  def update
    respond_to do |format|
      if @inventory_item.update(inventory_item_params)
        format.html { redirect_to @inventory_item, notice: t("inventory_items.flash.updated") }
        format.json { render :show, status: :ok, location: @inventory_item }
      else
        @categories = Category.for_account(Current.account).order(:name)
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @inventory_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @inventory_item.destroy!

    respond_to do |format|
      format.html { redirect_to inventory_items_path, status: :see_other, notice: t("inventory_items.flash.destroyed") }
      format.json { head :no_content }
    end
  end

  def add_to_shopping_list
    shopping_item = @inventory_item.add_to_shopping_list!
    redirect_to shopping_items_path, notice: t("inventory_items.flash.added_to_shopping_list")
  end

  private

  def set_inventory_item
    @inventory_item = InventoryItem.for_account(Current.account).find(params[:id])
  end

  def inventory_item_params
    params.expect(inventory_item: [ :name, :stock_state, :consumable, :category_id, :notes ])
  end
end
