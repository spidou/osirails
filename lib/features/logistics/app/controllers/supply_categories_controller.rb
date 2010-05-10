class SupplyCategoriesController < ApplicationController
  helper :supplies_manager
  
  before_filter :define_supply_type_and_supply_category_type
  before_filter :find_supply_category
  
  # GET /commodity_categories
  # GET /consumable_categories
  def index
    redirect_to send("#{@supply_type.name.tableize}_manager_path")
  end
  
  # GET /commodity_categories/:id
  # GET /consumable_categories/:id
  def show
  end
  
  # GET /commodity_categories/new
  # GET /consumable_categories/new
  def new
    @supply_category = @supply_category_type.new
  end
  
  # POST /commodity_categories
  # POST /consumable_categories
  def create
    @supply_category = @supply_category_type.new(params["#{@supply_category_type.name.underscore}".to_sym])
    if @supply_category.save
      flash[:notice] = "La famille a été créée"
      redirect_to send("#{@supply_type.name.tableize}_manager_path")
    else
      custom_callback
      render :action => 'new'
    end
  end
  
  def edit
    error_access_page(412) unless @supply_category.can_be_edited?
  end
    
  # PUT /commodity_categories/:id
  # PUT /consumable_categories/:id
  def update
    if @supply_category.can_be_edited?
      if @supply_category.update_attributes(params["#{@supply_category_type.name.underscore}".to_sym])
        flash[:notice] = "Le famille a été modifiée avec succès"
        redirect_to send("#{@supply_type.name.tableize}_manager_path")
      else
        custom_callback
        render :action => 'edit'
      end
    else
      error_access_page(412)
    end
  end
  
  # DELETE /commodity_categories/:id
  # DELETE /consumable_categories/:id
  def destroy
    if @supply_category.can_be_destroyed?
      if @supply_category.destroy
        flash[:notice] = "La famille a été supprimée avec succès"
      else
        flash[:error] = "Une erreur est survenue à la suppression de la famille"
      end
      redirect_to send("#{@supply_type.name.tableize}_manager_path")
    else
      error_access_page(412)
    end
  end
  
  # GET /commodity_categories/:commodity_category_id/disable
  # GET /consumable_categories/:consumable_category_id/disable
  def disable
    if @supply_category.can_be_disabled?
      if @supply_category.disable
        flash[:notice] = "La famille a été désactivée avec succès"
      else
        flash[:error] = "Une erreur est survenue à la désactivation de la famille"
      end
      redirect_to send("#{@supply_type.name.tableize}_manager_path")
    else
      error_access_page(412)
    end
  end
  
  # GET /commodity_categories/:commodity_category_id/enable
  # GET /consumable_categories/:consumable_category_id/enable
  def enable
    if @supply_category.can_be_enabled?
      if @supply_category.enable
        flash[:notice] = "La famille a été restaurée avec succès"
      else
        flash[:error] = "Une erreur est survenue à la restauration de la famille"
      end
      redirect_to send("#{@supply_type.name.tableize}_manager_path")
    else
      error_access_page(412)
    end
  end
  
  # GET /update_supply_sub_categories?id=:id (AJAX)
  def update_supply_sub_categories
    supply_categories = @supply_category ? @supply_category.children.enabled : []
    render :partial => 'supply_categories/supply_sub_categories', :object => supply_categories
  end
  
  private
    def find_supply_category
      id = params[:id] || params["#{@supply_category_type.name.underscore}_id".to_sym]
      @supply_category = @supply_category_type.find(id) unless id.blank?
    end
    
    def custom_callback
      # this method is defined here but it's redefined on sub classes
      # this method need to be called just before rendering in case presence of validation errors after create or update
      # has anybody a better idea to do what I want?
    end
end
