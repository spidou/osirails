class Commodity < Supply
  has_permissions :as_business_object, :class_methods => [:list, :view, :add, :edit, :delete, :disable, :enable]
  has_reference   :symbols => [ :supply_sub_category ], :prefix => :logistics
  
  acts_as_watchable :identifier_method => :designation
  
  belongs_to :supply_sub_category, :class_name => "CommoditySubCategory", :counter_cache => :supplies_count
  
  has_search_index  :only_attributes    => [ :reference, :name ],
                    :only_relationships => [ :supply_sub_category ],
                    :main_model         => true
end
