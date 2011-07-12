class ProductionStep < ActiveRecord::Base
  acts_as_step
  
  active_counter :model => 'Order', :callbacks => { :production_orders  => :after_save,
                                                    :production_total   => :after_save }
  
  has_search_index :only_attributes     => [ :status, :started_at, :finished_at ],
                   :only_relationships  => [ :order, :manufacturing_step ]
end
