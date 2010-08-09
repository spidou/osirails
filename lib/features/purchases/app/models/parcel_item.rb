class ParcelItem < ActiveRecord::Base
  has_permissions :as_business_object, :additional_class_methods => [ :cancel ]
  
  belongs_to :parcel
  belongs_to :purchase_order_supply
  belongs_to :canceller, :class_name => "User", :foreign_key => :cancelled_by_id
  belongs_to :issue_purchase_order_supply, :class_name => "PurchaseOrderSupply"
  
  validates_presence_of :purchase_order_supply_id
  validates_presence_of :purchase_order_supply, :if => :purchase_order_supply_id
  validates_presence_of :cancelled_comment, :if => :cancelled_at
  validates_presence_of :issues_comment, :if => :issued_at
  validates_presence_of :canceller, :if => :cancelled_by_id
  
  validates_numericality_of :quantity, :greater_than => 0
  validates_numericality_of :issues_quantity, :greater_than => 0, :if => :issued_at
  
  validate :validates_issue_quantity_for_parcel_item, :if => :issued_at
  validate :validates_quantity_for_parcel_item, :if => :new_record?
  
  attr_accessor :selected 
  attr_accessor :tmp_selected
  
  cattr_accessor :form_labels
  @@form_labels = Hash.new
  @@form_labels[:cancelled_comment]                       = "Veuillez saisir la raison de l'annulation :"
  @@form_labels[:purchase_document]                       = "Veuillez joindre le devis :"
  @@form_labels[:issues_comment]                          = "Commentaire :"
  @@form_labels[:issues_quantity]                         = "Quantit&eacute; &agrave; declarer :"
  @@form_labels[:must_be_reshipped]                       = "&Agrave; r&eacute;expedier par le fournisseur :"
  @@form_labels[:send_back_to_supplier]                   = "&Agrave; renvoyer au fournisseur :"
  
  after_save :save_issue_purchase_order_supply, :if => :issued_at
  
  before_validation_on_update :build_issue_purchase_order_supply, :if => :issued_at 
  validates_associated :issue_purchase_order_supply, :if => :issued_at 
  
  def quantity_to_i
    self.quantity.to_i
  end
  
  def build_issue_purchase_order_supply
    if self.must_be_reshipped && !self.issue_purchase_order_supply
      self.issue_purchase_order_supply = PurchaseOrderSupply.new(:purchase_order_id => self.purchase_order_supply.purchase_order_id,
                                                            :supply_id =>  self.purchase_order_supply.supply_id,
                                                            :quantity => self.issues_quantity,
                                                            :taxes => self.purchase_order_supply.taxes,
                                                            :fob_unit_price => self.purchase_order_supply.fob_unit_price,
                                                            :supplier_reference => self.purchase_order_supply.supplier_reference,
                                                            :supplier_designation => self.purchase_order_supply.supplier_designation)
    elsif self.issue_purchase_order_supply && self.must_be_reshipped_was && !self.must_be_reshipped
      self.issue_purchase_order_supply.destroy
      self.reload
    end
  end
   
  def save_issue_purchase_order_supply
    if self.must_be_reshipped && self.issue_purchase_order_supply
      self.issue_purchase_order_supply.quantity = self.issues_quantity
      self.issue_purchase_order_supply.save
    end
  end 
  
  def selected?
    self.selected.to_i == 1
  end
  
  def validates_quantity_for_parcel_item
    errors.add(:quantity, "quantity not valid")  if self.selected? && self.quantity > self.purchase_order_supply.remaining_quantity_for_parcel
  end
  
  def validates_issue_quantity_for_parcel_item
    errors.add(:issues_quantity, "quantity not valid")  if self.issues_quantity.to_i > self.quantity.to_i
  end
  
  def can_be_cancelled?
    !was_cancelled? and !new_record? and !parcel.was_received?
  end
  
  def can_be_reported?
    true if parcel.received? && !purchase_order_supply.purchase_order.was_completed? && !is_issued_purchase_order_supply_in_parcel?
  end
  
  def is_issued_purchase_order_supply_in_parcel?
    if issue_purchase_order_supply && issue_purchase_order_supply.parcel_items.any? && !issue_purchase_order_supply.are_parcel_or_parcel_items_all_cancelled?
      return true
    end
    return false
  end
  
  def was_reported?
    issued_at_was
  end
  
  def cancelled?
    cancelled_at
  end
  
  def was_cancelled?
    cancelled_at_was
  end
  
  def get_parcel_item_total
    quantity.to_f * purchase_order_supply.unit_price_including_tax.to_f
  end
  
  def cancel
    if can_be_cancelled?
      self.cancelled_at = Time.now
      self.save
    else
      false
    end
  end
  
  def report
    if can_be_reported?
      self.issued_at = Time.now
      return self.save
    end
    false
  end
end
