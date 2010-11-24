class Consumable < Supply
  has_permissions :as_business_object, :class_methods => [:list, :view, :add, :edit, :delete, :disable, :enable]
  has_reference   :symbols => [ :supply_sub_category ], :prefix => :logistics
  
  belongs_to :supply_sub_category, :class_name => "ConsumableSubCategory", :counter_cache => :supplies_count
  
  has_search_index  :only_attributes        => [ :reference, :name, :measure, :unit_mass ],
                    :additional_attributes  => { :humanized_supply_sizes  => :string,
                                                 :designation             => :string,
                                                 :average_unit_price      => :float,
                                                 :average_measure_price   => :float },
                    :only_relationships     => [ :supply_sub_category ]
end
