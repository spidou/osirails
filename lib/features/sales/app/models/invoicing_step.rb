class InvoicingStep < ActiveRecord::Base
  acts_as_step
  
  active_counter :model => 'Order', :callbacks => { :pre_invoicing_orders => :after_save,
                                                    :pre_invoicing_total  => :after_save,
                                                    :invoicing_orders     => :after_save,
                                                    :invoicing_total      => :after_save,
                                                    :in_progress_orders   => :after_save,
                                                    :in_progress_total    => :after_save }
  
  has_search_index :only_attributes     => [ :status, :started_at, :finished_at ],
                   :only_relationships  => [ :order, :invoice_step, :payment_step ]
end
