class ConsumableSubCategory < SupplySubCategory
  belongs_to :supply_category, :class_name => "ConsumableCategory"
  
  has_permissions :as_business_object, :class_methods => [:list, :view, :add, :edit, :delete, :disable, :enable]
  has_reference   :symbols => [ :supply_category ], :prefix => :logistics
  
  has_many :supplies, :class_name => "Consumable", :foreign_key => :supply_sub_category_id
  
  validates_presence_of :supply_category, :if => :supply_category_id
  
  validates_persistence_of :supply_category_id
  
  has_search_index  :only_attributes    => [ :id, :reference, :name ],
                    :only_relationships => [ :supply_category, :supplies ],
                    :identifier         => :name
end
