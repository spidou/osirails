class Commodity < Supply
  has_permissions :as_business_object, :class_methods => [:list, :view, :add, :edit, :delete, :disable, :enable]
  has_reference   :symbols => [ :supply_type ], :prefix => :logistics
  
  acts_as_watchable :identifier_method => :designation
  
  belongs_to :supply_type, :class_name => 'CommodityType', :counter_cache => :supplies_count
  
  journalize :attributes        => [:reference, :measure, :unit_mass, :packaging, :threshold, :enabled, :disabled_at],
             :subresources      => [:supplier_supplies],
             :identifier_method => Proc.new{ |s| "#{s.reference} - #{s.designation}" }
  
  has_search_index  :only_attributes        => [ :reference, :measure, :unit_mass ],
                    :additional_attributes  => { :humanized_supply_sizes  => :string,
                                                 :designation             => :string,
                                                 :average_unit_price      => :float,
                                                 :average_measure_price   => :float },
                    :only_relationships     => [ :supply_type ]
end
