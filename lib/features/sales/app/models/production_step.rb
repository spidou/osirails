class ProductionStep < ActiveRecord::Base
  acts_as_step
  
  active_counter :model => 'Order', :callbacks => { :production_orders  => :after_save,
                                                    :production_total   => :after_save }
end
