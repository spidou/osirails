class CommodityCategory < SupplyCategory
  has_permissions :as_business_object, :class_methods => [:list, :view, :add, :edit, :delete, :disable, :enable]
  has_reference   :prefix => :logistics
  
  has_many :sub_categories, :class_name => "CommoditySubCategory", :foreign_key => :supply_category_id
  
  has_search_index  :only_attributes    => [ :reference, :name ],
                    :only_relationships => [ :sub_categories ],
                    :main_model         => true
end
