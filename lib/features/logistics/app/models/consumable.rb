class Consumable < Supply
  # Validates
  validates_presence_of :consumable_category_id
  validates_presence_of :consumable_category, :if => :consumable_category_id

  # Relationship
  belongs_to :consumable_category, :counter_cache => true
  
  # This method permit to actualize counter_cache if a consumable is disable
  def counter_update(value = -1)
    parent = ConsumableCategory.find(self.consumable_category_id)
    ConsumableCategory.update_counters(parent.id, :consumables_count => value)
  end
  
end
