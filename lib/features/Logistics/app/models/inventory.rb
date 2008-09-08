class Inventory < ActiveRecord::Base
  include Permissible
    
  # Relationship
  has_many :commodities_inventories
  has_many :commodities, :through => :commodities_inventories
  
  # This methods permit to create a inventory with current commodities
  def create_inventory(commodities)
    commodities.each do |commodity|
      commodity_category = CommodityCategory.find(commodity.commodity_category_id)
      parent_commodity_category = CommodityCategory.find(commodity_category.commodity_category_id)
      self.commodities_inventories.create({
          :name => commodity.name,
          :fob_unit_price => commodity.fob_unit_price,
          :taxe_coefficient => commodity.taxe_coefficient,
          :measure => commodity.measure,
          :unit_mass => commodity.unit_mass,
          :unit_measure_id => commodity_category.unit_measure_id,
          :supplier_id => commodity.supplier_id,
          :commodity_category_id => commodity_category.id,
          :commodity_category_name => commodity_category.name,
          :parent_commodity_category_id => parent_commodity_category.id,
          :parent_commodity_category_name => parent_commodity_category.name})
    end  
  end
  
  # This method permit to check if a inventory is closed
  def inventory_closed?
    self.closed
  end
  
end