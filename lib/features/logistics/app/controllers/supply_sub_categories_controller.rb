class SupplySubCategoriesController < SupplyCategoriesController
  before_filter :define_supply_type_and_supply_category_type
  before_filter :find_supply_categories, :only => [ :show, :new, :create, :edit, :update ]
  
  before_filter :find_or_build_supply_categories_supply_sizes, :only => [ :show, :new, :edit ]
  
  # GET /commodity_categories/new
  # GET /consumable_categories/new
  # GET /commodity_categories/new?parent_id=:parent_id
  # GET /consumable_categories/new?parent_id=:parent_id
  def new
    parent_category_id = @supply_parent_category_type.find_by_id(params[:parent_id]).id rescue nil
    @supply_category = @supply_category_type.new( :supply_category_id => ( parent_category_id ) )
  end
  
  # GET /update_supply_unit_measure?id=:id (AJAX)
  def update_supply_unit_measure
    if @supply_category and @supply_category.unit_measure
      @symbol = @supply_category.unit_measure.symbol.to_s
    else
      @symbol = ""
    end
    render :template => 'supply_categories/update_supply_unit_measure'
  end
  
  private
    def find_supply_categories
      @supply_categories = @supply_parent_category_type.enabled
    end
    
    def custom_callback
      find_or_build_supply_categories_supply_sizes
    end
    
    def find_or_build_supply_categories_supply_sizes
      if @supply_category
        @supply_categories_supply_sizes = SupplySize.all.collect do |supply_size|
          if supply_categories_supply_size = @supply_category.supply_categories_supply_sizes.detect{ |i| i.supply_size_id == supply_size.id }
            supply_categories_supply_size
          else
            if params[:action] == "show"
              # don't build anything
            elsif params[:action] == "update" # return a new record
              SupplyCategoriesSupplySize.new(:supply_sub_category_id => @supply_category.id, :supply_size_id => supply_size.id)
            else # return a builded new record (which is also built in relationship accessor)
              @supply_category.supply_categories_supply_sizes.build(:supply_size_id => supply_size.id)
            end
          end
        end.compact
      else
        @supply_categories_supply_sizes = SupplySize.all.collect do |supply_size|
          SupplyCategoriesSupplySize.new(:supply_size_id => supply_size.id)
        end
      end
    end
end
