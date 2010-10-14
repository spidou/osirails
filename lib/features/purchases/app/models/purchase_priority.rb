class PurchasePriority < ActiveRecord::Base
  acts_as_list 
  
  validates_uniqueness_of :name
  before_save :update_default
  
  def update_default
    if self.default && default_purchase_priority = PurchasePriority.default_priority
      default_purchase_priority.update_attribute(:default, false)
    end
  end
  
  def self.default_priority
    PurchasePriority.first(:conditions => ["purchase_priorities.default = ?", 1]) || PurchasePriority.first 
  end
  
end
