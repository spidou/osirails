class Inventory < ActiveRecord::Base
  
  # Relationship
  has_many :commodities_inventories
  has_many :commodities, :through => :commodities_inventories
  
  # This methods permit to create a inventory with current commodities
  def create_inventory(commodities)
    commodities.each do |commodity|
      commodity_category = CommodityCategory.find(commodity.commodity_category_id)
      self.commodities_inventories.create({:name => commodity.name, :fob_unit_price => commodity.fob_unit_price, :taxe_coefficient => commodity.taxe_coefficient, :measure => commodity.measure, :unit_mass => commodity.unit_mass, :commodity_id => commodity.id, :unit_measure_id => commodity_category.unit_measure_id, :supplier_id => commodity.supplier_id})
    end  
  end
  
end