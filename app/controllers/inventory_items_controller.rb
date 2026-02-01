class InventoryItemsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_inventory_item, only: [ :show, :edit, :update, :destroy, :add_to_shopping_list, :update_stock_state ]

  def index
    @stock_filter = params[:stock_state] || "all"
    @category_filter = params[:category_id].presence
    @category_filter = nil if @category_filter == "all"

    @inventory_items = InventoryItem.for_account(Current.account).includes(:category)

    if @stock_filter != "all"
      @inventory_items = @inventory_items.where(stock_state: @stock_filter)
    end

    if @category_filter.present?
      @inventory_items = if @category_filter == "uncategorized"
        @inventory_items.where(category_id: nil)
      else
        @inventory_items.where(category_id: @category_filter)
      end
    end

    @categories_for_filter = Category.for_account(Current.account)
      .joins(:inventory_items)
      .where(inventory_items: { account_id: Current.account.id })
      .distinct
      .order(:name)

    @grouped_inventory_items = build_grouped_inventory_items(@inventory_items)
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
      format.html { redirect_to inventory_items_path(**index_path_options_for_redirect), status: :see_other, notice: t("inventory_items.flash.destroyed") }
      format.json { head :no_content }
    end
  end

  def add_to_shopping_list
    @inventory_item.add_to_shopping_list!
    redirect_to inventory_items_path(**index_path_options_for_redirect), notice: t("inventory_items.flash.added_to_shopping_list")
  end

  def update_stock_state
    @stock_filter = params[:stock_state_filter].presence || "all"
    @category_filter = params[:category_id].presence
    @category_filter = nil if @category_filter == "all"
    new_state = params[:stock_state].presence_in(%w[in_stock low empty])
    if new_state
      @inventory_item.update!(stock_state: new_state)
      respond_to do |format|
        format.html { redirect_to inventory_items_path(**index_path_options), notice: t("inventory_items.flash.updated") }
        format.turbo_stream do
          if @stock_filter != "all" && @inventory_item.stock_state != @stock_filter
            render turbo_stream: turbo_stream.remove(dom_id(@inventory_item)), status: :ok
          else
            render turbo_stream: turbo_stream.replace(dom_id(@inventory_item), partial: "inventory_items/card", locals: { inventory_item: @inventory_item, stock_filter: @stock_filter, category_filter: @category_filter }), status: :ok
          end
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to inventory_items_path(**index_path_options), alert: t("inventory_items.flash.invalid_stock_state") }
        format.turbo_stream { head :unprocessable_entity }
      end
    end
  end

  private

  def set_inventory_item
    @inventory_item = InventoryItem.for_account(Current.account).find(params[:id])
  end

  def inventory_item_params
    params.expect(inventory_item: [ :name, :stock_state, :consumable, :category_id, :notes ])
  end

  def index_path_options
    opts = { stock_state: @stock_filter }
    opts[:category_id] = @category_filter if @category_filter.present?
    opts
  end

  def index_path_options_for_redirect
    @stock_filter = params[:stock_state].presence || "all"
    @category_filter = params[:category_id].presence
    @category_filter = nil if @category_filter == "all"
    index_path_options
  end

  def build_grouped_inventory_items(items)
    grouped = items.group_by(&:category_id)
    category_ids = grouped.keys.compact
    categories_ordered = Category.where(id: category_ids).order(:name)
    result = categories_ordered.map { |cat| [ cat, grouped[cat.id].sort_by(&:name) ] }
    result << [ nil, grouped[nil].sort_by(&:name) ] if grouped.key?(nil)
    result
  end
end
