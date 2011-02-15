class CommodityType < SupplyType
  belongs_to :supply_sub_category, :class_name => 'CommoditySubCategory', :foreign_key => :supply_category_id
  
  has_many :supplies, :class_name => 'Commodity', :foreign_key => :supply_type_id
  
  has_reference :symbols => [ :supply_sub_category ], :prefix => :logistics
  
  has_search_index :only_attributes     => [ :reference, :name ],
                   :only_relationships  => [ :supply_sub_category ]
end
