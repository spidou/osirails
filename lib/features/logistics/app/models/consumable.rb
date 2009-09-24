class Consumable < Supply
  # Validates
  validates_uniqueness_of :name, :reference
  validates_presence_of :consumable_category_id
  validates_presence_of :consumable_category, :if => :consumable_category_id

  # Relationship
  belongs_to :consumable_category, :counter_cache => true
  
  # This method returns all supplies was_enabled at a given date
  # TODO with a named_scope (with argument) or not ?
  def self.was_enabled_at(date=Date.today)
    self.find(:all, :conditions => ["(enable = 1) OR (enable = 0 AND disabled_at > ?)", date])
  end  

  # This method returns all the restockables
  # supplies. They are defined by a stock less than 10%
  # above the given threshold
  def self.restockables
    @supplies_to_restock = []
    self.was_enabled_at.each {|supply|
      if supply.stock_quantity < (supply.threshold + supply.threshold*0.1)
        @supplies_to_restock << supply
      end
    }
    @supplies_to_restock
  end
  
  # This method return the entire stock values
  def self.stock_value(date=Date.today)
    total = 0.0
    for consumable in Consumable.was_enabled_at(date)
      total += consumable.stock_value(date)
    end
    total
  end  
end
