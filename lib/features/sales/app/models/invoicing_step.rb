class InvoicingStep < ActiveRecord::Base
  acts_as_step
  
  active_counter :model => 'Order', :callbacks => { :invoicing_orders  => :after_save,
                                                    :invoicing_total   => :after_save }
end
