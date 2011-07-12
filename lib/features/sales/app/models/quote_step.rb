class QuoteStep < ActiveRecord::Base
  has_permissions :as_business_object
  acts_as_step :remarks => false, :checklists => false
  
  active_counter :model => 'Order', :callbacks => { :commercial_orders  => :after_save,
                                                    :commercial_total   => :after_save }

  has_search_index :only_attributes => [ :status, :started_at, :finished_at ]
end
