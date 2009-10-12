class EstimateStep < ActiveRecord::Base
  has_permissions :as_business_object
  acts_as_step :remarks => false, :checklists => false
  
  has_many :quotes, :order => 'created_at DESC'
  
  has_one :pending_quote, :class_name => 'Quote', :conditions => [ 'status IN (?)', [ Quote::STATUS_VALIDATED, Quote::STATUS_SENDED ] ]
  has_one :signed_quote,  :class_name => 'Quote', :conditions => [ "status = ?", Quote::STATUS_SIGNED ]
  
  validates_associated :quotes
  #TODO validate if the estimate_step counts only one signed quote at time!
end
