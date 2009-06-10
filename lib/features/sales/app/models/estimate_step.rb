class EstimateStep < ActiveRecord::Base
  acts_as_step :remarks => false, :checklists => false
  
  has_many :quotes
  has_one :validated_quote, :class_name => "Quote", :conditions => [ "validated = ?", true ]
  
  validates_associated :quotes
  #TODO validate if the estimate_step counts only one validated quote at time!
end
