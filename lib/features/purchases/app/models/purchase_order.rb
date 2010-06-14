class PurchaseOrder < ActiveRecord::Base

  #status
  STATUS_DRAFT = "Brouillon"
  STATUS_VALIDATED = "Validé"
  
  #relationships
  has_many :purchase_order_supplies
  
  def draft?
    return false
  end
  
  def confirmed?
    return false
  end
end
