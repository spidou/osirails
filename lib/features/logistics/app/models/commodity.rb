class Commodity < Supply
  # Validates
  validates_presence_of :commodity_category_id
  validates_presence_of :commodity_category, :if => :commodity_category_id

  # Relationship
  belongs_to :commodity_category, :counter_cache => true
  
  # This method permit to actualize counter_cache if a commodity is disable
  def counter_update(value = -1)
    parent = CommodityCategory.find(self.commodity_category_id)
    CommodityCategory.update_counters(parent.id, :commodities_count => value)
  end
  
end
