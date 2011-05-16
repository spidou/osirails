## DATABASE STRUCTURE
# A integer  "quote_id"
# A integer  "quotable_id"
# A string   "quotable_type"
# A string   "name"
# A text     "description"
# A integer  "width"
# A integer  "length"
# A integer  "height"
# A decimal  "unit_price",       :precision => 65, :scale => 20
# A decimal  "prizegiving",      :precision => 65, :scale => 20
# A float    "quantity"
# A float    "vat"
# A integer  "position"
# A boolean  "pro_rata_billing"
# A datetime "created_at"
# A datetime "updated_at"

class QuoteItem < ActiveRecord::Base
  include ProductBase
  include ProductDimensions
  
  belongs_to :quote
  belongs_to :quotable, :polymorphic => true
  
  validates_presence_of :name
  
  validates_numericality_of :unit_price, :vat, :quantity, :unless => :free_item?
  validates_numericality_of :prizegiving, :allow_blank => true
  
  validates_associated :quotable
  
  journalize :attributes        => [:name, :description, :width, :length, :height, :unit_price, :prizegiving,
                                    :quantity, :vat, :position, :pro_rata_billing],
             :identifier_method =>  Proc.new{ |i| "#{i.designation_with_dimensions} (x #{i.quantity})" }
  
  # store a polymorphic referential object (product_reference for product_item, and service_delivery for service_item)
  attr_accessor :reference_object_type, :reference_object_id
  
  attr_accessor :should_destroy, :order_id
  
  before_validation :build_or_update_quotable
  
  after_save :save_quotable
  
  after_destroy :destroy_quotable
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def initialize(*params)
    super(*params)
    self.order_id = quote.order_id if quote
  end

  def after_find
    self.order_id = quote.order_id if quote # `if quote` added to avoid raise on quote_item_ids call, see next link for further explanations: http://github.com/rails/rails/commit/b163d83b8bab9103dc0e73b86212c2629cb45ca2
  end
  
  #TODO test this method
  def reference_object_type
    @reference_object_type ||= if is_product?
      "ProductReference"
    elsif is_service?
      "ServiceDelivery"
    end
  end
  
  #TODO test this method
  def reference_object_id
    @reference_object_id ||= if is_product? && quotable
      quotable.product_reference_id
    elsif is_service? && quotable
      quotable.service_delivery_id
    end
  end
  
  #TODO test this method
  def reference_object
    reference_object_type.constantize.find_by_id(reference_object_id) if reference_object_type
  end
  
  def order
    Order.find_by_id(order_id)
  end
  
  def free_item?
    quotable.nil? and reference_object_id.blank?
  end
  
  def product_item?
    !free_item? and is_product?
  end
  
  def service_item?
    !free_item? and is_service?
  end
  
  #TODO test this method
  def pro_rata_billing?
    pro_rata_billing == true || pro_rata_billing == "1" || pro_rata_billing == 1
  end
  
  #TODO test this method
  def build_or_update_quotable
    return if free_item?
    
    common_attributes       = %w( name description unit_price prizegiving quantity vat position )
    only_product_attributes = %w( width length height )
    only_service_attributes = %w( pro_rata_billing )
    replicated_attributes   = []
    
    if product_item?
      self.quotable ||= order.end_products.build(:product_reference_id => reference_object_id)
      replicated_attributes = common_attributes + only_product_attributes
    elsif service_item?
      self.quotable ||= order.orders_service_deliveries.build(:service_delivery_id => reference_object_id)
      replicated_attributes = common_attributes + only_service_attributes
    end
    
    replicated_attributes.each do |attr|
      self.quotable.send("#{attr}=", self.send(attr))
    end
    
    return self.quotable
  end
  
  #TODO test this method
  def save_quotable
    quotable.save(false) unless free_item?
  end
  
  #TODO test this method
  def destroy_quotable
    quotable.destroy if !free_item? and Quote.find_by_id(quote.id)
  end
  
  def reference
    reference_object && reference_object.reference
  end
  
  def name
    self[:name] ||= reference_object && reference_object.designation
  end
  
  def description
    self[:description] ||= reference_object && reference_object.description
  end
  
  def width
    self[:width] ||= reference_object && reference_object.width
  end
  
  def length
    self[:length] ||= reference_object && reference_object.length
  end
  
  def height
    self[:height] ||= reference_object && reference_object.height
  end
  
  def vat
    self[:vat] ||= reference_object && reference_object.vat
  end
  
  def unit_price
    if is_service? && reference_object
      self[:unit_price] ||= reference_object.unit_price
    else
      self[:unit_price]
    end
  end
  
  def original_name
    free_item? ? nil : reference_object && reference_object.designation
  end
  
  def original_description
    free_item? ? nil : reference_object && reference_object.description
  end
  
  def original_vat
    free_item? ? nil : reference_object && reference_object.vat
  end
  
  def designation
    name
  end
  
  def designation_with_dimensions
    product_item? ? designation + ( dimensions.blank? ? "" : " (#{dimensions})" ) : designation
  end
  
  def position # used by Quote#sorted_quote_items
    super || 0
  end
  
  private
    def is_product?
      ( quotable && quotable.instance_of?(EndProduct) ) || ( quotable_type && quotable_type == "EndProduct" )
    end
    
    def is_service?
      ( quotable && quotable.instance_of?(OrdersServiceDelivery) ) || ( quotable_type && quotable_type == "OrdersServiceDelivery" )
    end
  
end
