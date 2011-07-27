class DeliveryStep < ActiveRecord::Base
  has_permissions :as_business_object
  acts_as_step
  
  active_counter :model => 'Order', :callbacks => { :delivering_orders  => :after_save,
                                                    :delivering_total   => :after_save }
  
  has_search_index :only_attributes => [ :status, :started_at, :finished_at ]
end
