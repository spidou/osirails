## DATABASE STRUCTURE
# A integer  "order_id"
# A integer  "service_delivery_id"
# A string   "name"
# A text     "description"
# A decimal  "unit_price",          :precision => 65, :scale => 20
# A decimal  "prizegiving",         :precision => 65, :scale => 20
# A float    "quantity"
# A float    "vat"
# A integer  "position"
# A boolean  "pro_rata_billing",                                    :default => false
# A datetime "cancelled_at"
# A datetime "created_at"
# A datetime "updated_at"
    
class OrdersServiceDelivery < ActiveRecord::Base
  include ProductBase
  
  belongs_to :order
  belongs_to :service_delivery
  
  has_many :quote_items, :as => :quotable
  
  validates_presence_of :name
  
  validates_numericality_of :unit_price, :vat, :quantity
  validates_numericality_of :prizegiving, :allow_blank => true
  
  attr_accessor :dimensions # this is just for support methods applied both to end_product and orders_service_delivery (see QuoteItem#build_or_update_quotable)
  
  #TODO test that method
  def enabled?
    !cancelled_at
  end
  
  #TODO test that method
  def was_enabled?
    !cancelled_at_was
  end
  
  #TODO test that method
  def disable
    self.cancelled_at = Time.now
    self.save
  end
  
  def pro_rata_billing?
    pro_rata_billing == true
  end
  
  def reference
    service_delivery && service_delivery.reference
  end
  
  def name
    self[:name] ||= service_delivery && service_delivery.name
  end
  alias :designation :name
  
  def description
    self[:description] ||= service_delivery && service_delivery.description
  end
  
  def unit_price
    self[:unit_price] ||= service_delivery && service_delivery.unit_price
  end
  
  def vat
    self[:vat] ||= service_delivery && service_delivery.vat
  end
  
  # return if the order_service_delivery is present into an active invoice (where status != cancelled)
  def billed?
    order.invoices.actives.collect(&:service_invoice_items).flatten.collect(&:invoiceable).include?(self)
  end
  
  # return if the order_service_delivery is present into a confirmed invoice (where status >= confirmed)
  def billed_and_confirmed?
    order.invoices.billed.collect(&:service_invoice_items).flatten.collect(&:invoiceable).include?(self)
  end
end
