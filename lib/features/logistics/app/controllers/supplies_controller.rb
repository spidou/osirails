class SuppliesController < ApplicationController
  helper :supplies_manager, :supplies, :supplier_supplies
  
  before_filter :define_classes
  before_filter :find_supply,           :except => [ :update_supplies_supply_sizes ]
  before_filter :load_collections,      :only   => [ :new, :create, :edit, :update ]
  before_filter :find_supply_ancestors, :only   => [ :new, :create, :edit, :update ]
  before_filter :find_suppliers,        :only   => [ :new, :create ]
  before_filter :find_unit_measure,     :only   => [ :show, :new, :create, :edit, :update ]
  
  before_filter :find_or_build_supplies_supply_sizes, :only => [ :show, :edit ]

  # GET /commodities
  # GET /consumables
  def index
    redirect_to :controller => "#{@supply_class.name.tableize}_manager", :action => 'index'
  end
  
  # GET /commodities/:id
  # GET /consumables/:id
  def show
  end
  
  # GET /commodities/new
  # GET /consumables/new
  #
  # GET /commodities/new?supply_category_id=:supply_category_id
  # GET /consumables/new?supply_category_id=:supply_category_id
  #
  # GET /commodities/new?supply_sub_category_id=:supply_sub_category_id
  # GET /consumables/new?supply_sub_category_id=:supply_sub_category_id
  #
  # GET /commodities/new?supply_type_id=:supply_type_id
  # GET /consumables/new?supply_type_id=:supply_type_id
  def new
    @supply = @supply_class.new( :supply_category_id      => ( @supply_category.id rescue nil ),
                                 :supply_sub_category_id  => ( @supply_sub_category.id rescue nil ),
                                 :supply_type_id          => ( @supply_type.id rescue nil ) )
    find_or_build_supplies_supply_sizes
  end
  
  # POST /commodities
  # POST /consumables
  def create
    @supply = @supply_class.new(:supply_sub_category_id => params[@supply_class.name.underscore.to_sym].delete(:supply_sub_category_id)) #:supply_sub_category_id is required for other setter methods
    @supply.attributes = params[@supply_class.name.underscore.to_sym]
    
    if @supply.save
      flash[:notice] = "L'article a été créé avec succès"
      redirect_to @supply
    else
      find_or_build_supplies_supply_sizes
      render :action => 'new'
    end
  end

  # GET /commodities/:id/edit
  # GET /consumables/:id/edit
  def edit
  end

  # PUT /commodities/:id
  # PUT /consumables/:id
  def update
    if @supply.update_attributes(params["#{@supply_class.name.underscore}".to_sym])
      flash[:notice] = "L'article a été modifié avec succès"
      redirect_to @supply
    else
      find_or_build_supplies_supply_sizes
      render :action => 'edit'
    end
  end

  # DELETE /commodities/:id
  # DELETE /consumables/:id
  def destroy
    if @supply.destroy
      flash[:notice] = "L'article a été supprimé avec succès"
    else
      flash[:error] = "Une erreur est survenue à la suppression de l'article"
    end
    redirect_to :controller => "#{@supply_class.name.tableize}_manager", :action => 'index'
  end
  
  # GET /commodities/:commodity_id/disable
  # GET /consumables/:consumable_id/disable
  def disable
    if @supply.disable
      flash[:notice] = "L'article a été désactivé avec succès"
    else
      flash[:error] = "Une erreur est survenue à la désactivation de l'article"
    end
    redirect_to :controller => "#{@supply_class.name.tableize}_manager", :action => 'index'
  end
  
  # GET /commodities/:commodity_id/enable
  # GET /consumables/:consumable_id/enable
  def enable
    if @supply.enable
      flash[:notice] = "L'article a été restauré avec succès"
    else
      flash[:error] = "Une erreur est survenue à la restauration de l'article"
    end
    redirect_to :controller => "#{@supply_class.name.tableize}_manager", :action => 'index'
  end
  
  # GET /update_commodity_supply_sizes?parent_id=:parent_id
  # GET /update_consumable_supply_sizes?parent_id=:parent_id
  def update_supplies_supply_sizes
    @supply = @supply_class.new(:supply_sub_category_id => params[:parent_id])
    find_or_build_supplies_supply_sizes
    
    render :partial => 'supplies_supply_sizes/supplies_supply_sizes_list', :object => @supplies_supply_sizes,
                                                                           :locals => { :supply => @supply }
  end
  
  private
    def define_classes
      @supply_class = Supply
      @supply_category_class = SupplyCategory
      @supply_sub_category_class = SupplySubCategory
      @supply_type_class = SupplyType
    end
    
    def find_supply
      id = params[:id] || params["#{@supply_class.name.underscore}_id".to_sym]
      @supply = @supply_class.find(id) if id
    end
    
    def load_collections
      @supply_categories = @supply_category_class.enabled
      @supply_sub_categories = @supply_sub_category_class.enabled
      @supply_types = @supply_type_class.enabled
    end
    
    def find_supply_ancestors
      @supply_type = @supply_types.find_by_id(params[:supply_type_id]) || @supply.supply_type rescue nil
      @supply_sub_category = ( @supply_type && @supply_type.supply_sub_category ) || @supply_sub_categories.find_by_id(params[:supply_sub_category_id]) || @supply.supply_sub_category rescue nil
      @supply_category = ( @supply_sub_category && @supply_sub_category.supply_category ) || @supply_categories.find_by_id(params[:supply_category_id]) || @supply.supply_category rescue nil
    end
    
    def find_suppliers
      @suppliers = Supplier.find(:all)    
    end
    
    def find_unit_measure
      @unit_measure = UnitMeasure.find_by_id(@supply.unit_measure.id) if @supply and @supply.unit_measure
    end
    
    def find_or_build_supplies_supply_sizes
      if @supply and sub_category = @supply.supply_sub_category
        @supplies_supply_sizes = sub_category.supply_categories_supply_sizes.collect do |supply_categories_supply_size|
          if supplies_supply_size = @supply.supplies_supply_sizes.detect{ |i| i.supply_size_id == supply_categories_supply_size.supply_size_id }
            supplies_supply_size
          else
            if params[:action] == "show"
              # don't build anything
            elsif params[:action] == "update" # return a new record
              SuppliesSupplySize.new(:supply_id => @supply.id, :supply_size_id => supply_categories_supply_size.supply_size_id, :unit_measure_id => supply_categories_supply_size.unit_measure_id)
            else # return a builded new record (which is also built in relationship accessor)
              @supply.supplies_supply_sizes.build(:supply_size_id => supply_categories_supply_size.supply_size.id, :unit_measure_id => supply_categories_supply_size.unit_measure_id)
            end
          end
        end.compact
      else
        @supplies_supply_sizes = []
      end
    end
end
