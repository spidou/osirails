class CommercialStep < ActiveRecord::Base
  acts_as_step
  
  active_counter :model => 'Order', :callbacks => { :commercial_orders  => :after_save,
                                                    :commercial_total   => :after_save }
  
  has_search_index :only_attributes     => [ :status, :started_at, :finished_at ],
                   :only_relationships  => [ :order, :survey_step, :quote_step, :press_proof_step ]
end
