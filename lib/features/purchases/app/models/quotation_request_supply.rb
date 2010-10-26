class QuotationRequestSupply < ActiveRecord::Base
  has_permissions :as_business_object, :additional_class_methods => [ :cancel ]
  
  include PurchasesSuppliesBase
  
  has_many :quotation_request_purchase_request_supplies
  has_many :purchase_request_supplies, :through => :quotation_request_purchase_request_supplies
  
  belongs_to :quotation_request
  belongs_to :supply
  
  attr_accessor :purchase_request_supplies_ids, :purchase_request_supplies_deselected_ids, :should_destroy
  
  validates_presence_of :position
  validates_presence_of :supply, :if => :supply_id
  validates_presence_of :designation, :if => :free_supply_and_not_associated_prs?
  
  with_options :if => :comment_line? do |qr|
    qr.validates_presence_of :description
  end
  
  validates_numericality_of :quantity, :greater_than => 0, :unless => :comment_line?
  
  validates_uniqueness_of :supply_id, :scope => :quotation_request_id, :allow_blank => :true
  
  before_destroy :can_be_destroyed?
  
  #TODO test this method
  def can_be_cancelled?
    quotation_request.was_confirmed? and (!quotation_request.quotation or (quotation_request.quotation and quotation_request.quotation.was_drafted?))
  end
  
  def can_be_destroyed?
    !new_record? && quotation_request(true).was_drafted?
  end
  
  def existing_supply?
    supply ? true : false
  end
  
  def free_supply?
    !existing_supply? and !comment_line
  end
  
  def comment_line?
    existing_supply? ? false : comment_line
  end
end
