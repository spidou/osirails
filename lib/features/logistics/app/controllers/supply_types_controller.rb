class SupplyTypesController < ApplicationController
  before_filter :define_supply_type_class_and_supply_sub_category_class
  before_filter :find_supply_sub_category
  
  # GET /update_supply_types?id=:id (AJAX)
  def update_supply_types
    supply_types = @supply_sub_category ? @supply_sub_category.supply_types : []
    render :partial => 'supply_types/supply_types', :object => supply_types
  end
  
  private
    def find_supply_sub_category
      id = params[:id] || params["#{@supply_sub_category_class.name.underscore}_id".to_sym]
      @supply_sub_category = @supply_sub_category_class.find(id) unless id.blank?
    end
end
