class QuoteStep < ActiveRecord::Base
  has_permissions :as_business_object
  acts_as_step :remarks => false, :checklists => false
  
  active_counter :model => 'Order', :callbacks => { :commercial_orders  => :after_save,
                                                    :commercial_total   => :after_save }
end
