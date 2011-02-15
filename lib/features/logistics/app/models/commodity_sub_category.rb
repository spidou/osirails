class CommoditySubCategory < SupplySubCategory
  belongs_to :supply_category, :class_name => "CommodityCategory"
  
  has_permissions :as_business_object, :class_methods => [:list, :view, :add, :edit, :delete, :disable, :enable]
  has_reference   :symbols => [ :supply_category ], :prefix => :logistics
  
  has_many :supply_types, :class_name => 'CommodityType', :foreign_key => :supply_category_id
  
  has_search_index  :only_attributes    => [ :id, :reference, :name ],
                    :only_relationships => [ :supply_category, :supply_types ],
                    :identifier         => :name
end
