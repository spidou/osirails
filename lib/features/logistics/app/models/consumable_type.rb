class ConsumableType < SupplyType
  belongs_to :supply_sub_category, :class_name => 'ConsumableSubCategory', :foreign_key => :supply_category_id
  
  has_reference :symbols => [ :supply_sub_category ], :prefix => :logistics
  
  has_many :supplies, :class_name => 'Consumable', :foreign_key => :supply_type_id
  
  has_search_index :only_attributes     => [ :id, :reference, :name ],
                   :only_relationships  => [ :supply_sub_category ]
end
