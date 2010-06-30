class PurchaseOrderSupply < ActiveRecord::Base
  
  has_permissions :as_business_object, :additional_class_methods => [ :cancel ]
  
  has_many :request_order_supplies
  has_many :purchase_request_supplies, :through => :request_order_supplies
  
  has_one :former_purchase_order_supply, :foreign_key => "reshipped_purchase_order_supply", :class_name => "PurchaseOrderSupply"
   
  belongs_to :purchase_order
  belongs_to :parcel
  belongs_to :supply
  belongs_to :canceller, :foreign_key => "cancelled_by", :class_name => "User"
  belongs_to :reshipped_purchase_order_supply, :class_name => "PurchaseOrderSupply"
  
  STATUS_UNTREATED = nil
  STATUS_PROCESSING = "processing"
  STATUS_SENT_BACK = "sent_back"
#  STATUS_RESHIPPED = "reshipped"
#  STATUS_REIMBURSED = "reimbursed"
  STATUS_CANCELLED = "cancelled"
  
  attr_accessor :purchase_request_supplies_ids
  
  validates_presence_of :supply_id, :supplier_designation, :supplier_reference, :taxes
  validates_presence_of :cancelled_by, :if => :cancelled_at
  validates_presence_of :reshipped_purchase_order_supply_id, :if => :reship #
    
  validates_numericality_of :quantity, :fob_unit_price , :greater_than => 0
  validates_numericality_of :taxes, :greater_than_or_equal_to => 0

#  validates_inclusion_of :status, :in => [ STATUS_UNTREATED, STATUS_PROCESSING, STATUS_SENT_BACK, STATUS_RESHIPPED, STATUS_REIMBURSED, STATUS_CANCELLED ]
  validates_inclusion_of :status, :in => [ STATUS_UNTREATED, STATUS_PROCESSING, STATUS_CANCELLED ], :if => :was_untreated?
  validates_inclusion_of :status, :in => [ STATUS_PROCESSING, STATUS_CANCELLED, STATUS_SENT_BACK ], :if => :was_processing?
#  validates_inclusion_of :status, :in => [ STATUS_SENT_BACK, STATUS_RESHIPPED, STATUS_REIMBURSED ], :if => :was_sent_back?
#  validates_inclusion_of :status, :in => [ STATUS_RESHIPPED ], :if => :was_reshipped?
#  validates_inclusion_of :status, :in => [ STATUS_REIMBURSED ], :if => :was_reimbursed?
  
  validates_associated :request_order_supplies
  
  def untreated?
    status == STATUS_UNTREATED
  end
  
  def processing?
    status == STATUS_PROCESSING
  end
  
  def sent_back?
    status == STATUS_SENT_BACK
  end
  
  def reshipped?
    reshipped_purchase_order_supply_id != nil
  end
  
  def reimbursed?
    (status == STATUS_CANCELLED) and (sent_back_at != nil)
  end
  
  def cancelled?
    status == STATUS_CANCELLED
  end
  
  def completed?
    reshipped? or reimbursed? or ( processing? and parcel.received?)
  end
  
  def was_untreated?
    status_was == STATUS_UNTREATED
  end
  
  def was_processing?
    status_was == STATUS_PROCESSING
  end
  
  def was_sent_back?
    status_was == STATUS_SENT_BACK
  end
  
  def was_reshipped?
    reshipped_purchase_order_supply_id_was != nil
#    status_was == STATUS_RESHIPPED
  end
  
  def was_reimbursed?
    was_cancelled? and (sent_back_at != nil)
#    status_was == STATUS_REIMBURSED
  end
  
  def was_cancelled?
    status_was == STATUS_CANCELLED
  end
  
  def can_be_processed?
    was_untreated?
  end
  
  def can_be_sent_back?
    was_processing?
  end
  
  def can_be_reshipped?
    was_sent_back?
  end
  
  def can_be_reimbursed?
    was_sent_back?
  end
  
  def can_be_cancelled?
    (was_untreated? and purchase_order.was_confirmed? and ((parcel and parcel.was_processing) or !parcel)) or (was_processing? and purchase_order.was_confirmed? and parcel.was_processing?)
  end
  
  def can_be_deleted?
    new_record? or purchase_order.was_draft?
  end
  
  def treat
    if can_be_processing?
      self.status = STATUS_PROCESSING
      self.save
    else
      false
    end
  end
  
  def send_back
    if can_be_sent_back?
      self.status = STATUS_SENT_BACK
      self.sent_back_at = Time.now
      self.save
    else
      false
    end
  end
  
  def reship
    if can_be_reshipped?
      self.reshipped_at = Time.now
      self.save
    else
      false
    end
  end
  
  def reimburse
    if can_be_reimbursed?
      self.reimbursed_at = Time.now
      self.save
    else
      false
    end
  end
  
  def cancel(attributes)
    if can_be_cancelled?
      self.attributes = attributes
      self.status = STATUS_CANCELLED
      self.cancelled_at = Time.now
      self.save
    else
      false
    end
  end
  
  def is_reshipment?
    #TODO
  end
    
  def get_supplier_supply(supplier_id = purchase_order.supplier, supply_id = supply.id)
    SupplierSupply.find_by_supplier_id_and_supply_id(supplier_id, supply_id)
  end
  
  def get_unit_price_including_tax(supplier_id = purchase_order.supplier, supply_id = supply.id)
    return 0 unless get_supplier_supply(supplier_id, supply_id)
    supplier_supply = get_supplier_supply(supplier_id, supply_id)
    taxes = supplier_supply.taxes
    if fob_unit_price
      fob_unit_price
    else
      fob_unit_price = supplier_supply.unit_price
    end
    (supplier_supply.fob_unit_price * ((100 + taxes)/100))
  end
  
  def get_purchase_order_supply_total
    quantity.to_f * get_unit_price_including_tax.to_f
  end
  
  def get_taxes
    return taxes if taxes
    return 0 unless get_supplier_supply
    get_supplier_supply.taxes
  end
  
  def not_cancelled_purchase_request_supplies
    purchase_request_supplies = PurchaseRequestSupply.all(:include => :purchase_request,  :conditions =>['purchase_request_supplies.supply_id = ? AND purchase_request_supplies.cancelled_at IS NULL AND purchase_requests.cancelled_at IS NULL',supply_id])
  end
  
  def unconfirmed_purchase_request_supplies
    res = []
    for request_supply in not_cancelled_purchase_request_supplies
      res.push request_supply unless request_supply.confirmed_purchase_order_supply
    end
    res
  end
  
  def get_purchase_request_supplies_ids
    res = ""
      unconfirmed_purchase_request_supplies.each do |purchase_request_supply|
        if request_order_supplies.detect { |t| t.purchase_request_supply_id == purchase_request_supply.id.to_i }
          res += purchase_request_supply.id.to_s + ";"
        end
      end
    res
  end
  
  def boolean_checked(purchase_request_supply)
    return true if request_order_supplies.detect { |t| t.purchase_request_supply_id == purchase_request_supply.id.to_i }
    return false
  end
  
  def integer_checked(purchase_request_supply)
    return 1 if request_order_supplies.detect { |t| t.purchase_request_supply_id == purchase_request_supply.id.to_i }
    return 0
  end
  
  def get_purchase_order_supply_total
    quantity.to_f * get_unit_price_including_tax.to_f
  end
  
end
