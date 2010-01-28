class Commodity < Supply
  has_permissions :as_business_object, :class_methods => [:list, :view, :add, :edit, :delete, :disable, :reactivate]
  
  # Validates
  validates_uniqueness_of :name, :reference
  validates_presence_of :commodity_category_id
  validates_presence_of :supply_category, :if => :commodity_category_id

  # Relationship
  belongs_to :supply_category, :class_name => "CommodityCategory", :foreign_key => "commodity_category_id", :counter_cache => true

  # This method returns all the restockables
  # supplies. They are defined by a stock less than 10%
  # above the given threshold
  def self.restockables
    @supplies_to_restock = []
    for commodity in Commodity.find(:all)
      if (commodity.was_enabled_at and commodity.stock_quantity < (commodity.threshold + commodity.threshold*0.1))
        @supplies_to_restock << commodity
      end
    end
    @supplies_to_restock
  end
  
  # This method returns the entire stock values
  def self.stock_value(date = Date.today)
    total = 0.0
    for commodity in Commodity.find(:all)
      total += commodity.stock_value(date) if commodity.was_enabled_at(date)
    end
    total
  end  
  
  # This method returns all enabled supplies at a given date
  def self.was_enabled_at(date = Date.today)
    @enabled_supplies = []
    for commodity in Commodity.find(:all)
      @enabled_supplies << commodity if commodity.was_enabled_at(date)
    end
    @enabled_supplies
  end
end
