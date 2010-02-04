class Consumable < Supply
  has_permissions :as_business_object, :class_methods => [:list, :view, :add, :edit, :delete, :disable, :reactivate]
  
  # Validates
  validates_uniqueness_of :name, :reference
  validates_presence_of :consumable_category_id
  validates_presence_of :supply_category, :if => :consumable_category_id

  # Relationship
  belongs_to :supply_category, :class_name => "ConsumableCategory", :foreign_key => "consumable_category_id", :counter_cache => true

  # This method returns all the restockables
  # supplies. They are defined by a stock less than 10%
  # above the given threshold
  def self.restockables
    @supplies_to_restock = []
    for consumable in Consumable.find(:all)
      if (consumable.was_enabled_at and consumable.stock_quantity < (consumable.threshold + consumable.threshold*0.1))
        @supplies_to_restock << consumable
      end
    end
    @supplies_to_restock
  end
  
  # This method returns the entire stock values
  def self.stock_value(date=Date.today)
    total = 0.0
    for consumable in Consumable.find(:all)
      total += consumable.stock_value(date) if consumable.was_enabled_at(date)
    end
    total
  end  
  
  # This method returns all enabled supplies at a given date
  def self.was_enabled_at(date=Date.today)
    @enabled_supplies = []
    for consumable in Consumable.find(:all)
      @enabled_supplies << consumable if consumable.was_enabled_at(date)
    end
    @enabled_supplies
  end
end
