class PurchaseRequestSupply < ActiveRecord::Base
  
  #relationships
  belongs_to :purchase_request
  belongs_to :supply
  
  has_many  :request_order_supplies
  has_many  :purchase_order_supplies, :through => :request_order_supplies
  belongs_to :canceller, :class_name => "User", :foreign_key => 'cancelled_by'
  
  #validations
  validates_presence_of :supply_id
  validates_persistence_of :expected_delivery_date
  
  validates_numericality_of :expected_quantity, :greater_than => 0
  validates_date :expected_delivery_date, :after => Date.today, :if => :new_record?
  
  #method a refaire
  def check_status
    status = 'en cours de traitement'   
  end
  
  def cancelled?
    if self.cancelled_at or self.purchase_request.cancelled? 
      return true
    end
    return false 
  end
  
  def cancel
    self.cancelled_at = Time.now
    self.save
  end
  
  def untreated?
    self.request_order_supplies.empty? ? true : false
  end
  
  def during_treatment?
    self.request_order_supplies.each do |request_order_supply|
      return false unless request_order_supply.purchase_order.draft?
    end 
    self.request_order_supplies.any? ? true : false
  end
  
  def treated?
    self.request_order_supplies.each do |request_order_supply|
      return true if request_order_supply.purchase_order.confirmed?
    end 
    return false
  end
  
end
