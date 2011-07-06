class DeliveringStep < ActiveRecord::Base
  has_permissions :as_business_object
  acts_as_step
  
  active_counter :model => 'Order', :callbacks => { :delivery_orders  => :after_save,
                                                    :delivery_total   => :after_save }
end
