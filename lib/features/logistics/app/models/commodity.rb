class Commodity < Supply
  has_permissions :as_business_object, :class_methods => [:list, :view, :add, :edit, :delete, :disable, :enable]
  has_reference   :symbols => [ :supply_sub_category ], :prefix => :logistics
  
  belongs_to :supply_sub_category, :class_name => "CommoditySubCategory", :counter_cache => :supplies_count
end
