class CommercialStep < ActiveRecord::Base
  acts_as_step
  
  active_counter :model => 'Order', :callbacks => { :commercial_orders  => :after_save,
                                                    :commercial_total   => :after_save }
end
