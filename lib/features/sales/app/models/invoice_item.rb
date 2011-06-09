## DATABASE STRUCTURE
# A integer  "invoice_id"
# A integer  "invoiceable_id"
# A string   "invoiceable_type"
# A integer  "position"
# A float    "quantity"
# A string   "name"
# A text     "description"
# A decimal  "unit_price",     :precision => 65, :scale => 20
# A float    "vat"
# A datetime "created_at"
# A datetime "updated_at"
    
class InvoiceItem < ActiveRecord::Base
  include ProductBase
  
  belongs_to :invoice
  belongs_to :invoiceable, :polymorphic => true
  
  # TODO test that validates
  validates_numericality_of :unit_price, :quantity, :vat, :if => Proc.new{ |i| (i.unit_price and i.unit_price > 0) or (i.quantity and i.quantity > 0) or (i.vat and i.vat > 0) }
  
  # TODO test that validates
  validates_presence_of :name, :unless => :should_destroy? # don't validate presence of name if the item will be destroyed
  
  validates_persistence_of :invoiceable_id, :invoiceable_type
  
  journalize :attributes        => [:name, :description, :unit_price, :quantity, :vat],
             :identifier_method => Proc.new{ |i| "#{i.name} (x #{i.quantity})" }
  
  attr_accessor :reference_object_type, :reference_object_id
  attr_accessor :should_destroy
  
  #TODO test this method
  # should_destroy accessor is only used for free_item, and quantity.zero? is used for product_item
  def should_destroy?
    ( !free_item? and quantity.zero? ) or ( free_item? and should_destroy.to_i == 1 )
  end
  
  #TODO test this method
  def free_item?
    invoiceable_id.nil?
  end
  
  #TODO test this method
  def product_item?
    ( invoiceable && invoiceable.instance_of?(EndProduct) ) || ( invoiceable_type && invoiceable_type == "EndProduct" )
  end
  
  #TODO test this method
  def service_item?
    ( invoiceable && invoiceable.instance_of?(OrdersServiceDelivery) ) || ( invoiceable_type && invoiceable_type == "OrdersServiceDelivery" )
  end
  
  #TODO test this method
  def reference_object_type
    @reference_object_type ||= if product_item?
      "ProductReference"
    elsif service_item?
      "ServiceDelivery"
    end
  end
  
  #TODO test this method
  def reference_object_id
    @reference_object_id ||= if product_item?
      invoiceable && invoiceable.product_reference_id
    elsif service_item?
      invoiceable && invoiceable.service_delivery_id
    end
  end
  
  #TODO test this method
  def reference_object
    reference_object_type.constantize.find_by_id(reference_object_id) if reference_object_type
  end
  
  #TODO test this method
  def quantity
    self[:quantity] ||= invoiceable && invoiceable.quantity
  end
  
  #TODO test this method
  def name
    if free_item?
      super
    elsif invoiceable
      if product_item?
        invoiceable.designation_with_dimensions
      else
        invoiceable.designation
      end
    end
  end
  
  #TODO test this method
  def description
    free_item? ? super : invoiceable && invoiceable.description
  end
  
  #TODO test this method
  def unit_price
    free_item? ? super : invoiceable && invoiceable.unit_price
  end
  
  #TODO test this method
  def vat
    free_item? ? super : invoiceable && invoiceable.vat
  end
  
  #TODO test this method
  def prizegiving
    free_item? ? 0.0 : invoiceable && invoiceable.prizegiving
  end
  
  #TODO test this method
  def position # used for sorted_invoice_items
    super || 0
  end
end
