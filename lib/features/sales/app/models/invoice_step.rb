class InvoiceStep < ActiveRecord::Base
  has_permissions :as_business_object
  acts_as_step
  
  active_counter :model => 'Order', :callbacks => { :invoicing_orders  => :after_save,
                                                    :invoicing_total   => :after_save }
end
