class QuoteItem < ActiveRecord::Base
  include ProductBase
  
  belongs_to :quote
  belongs_to :product
  
  acts_as_list :scope => :quote
  
  has_many :delivery_note_items, :dependent => :nullify
  has_many :delivery_notes,      :through   => :delivery_note_items
  
  validates_presence_of :name, :description, :dimensions
  
  validates_numericality_of :unit_price, :vat, :quantity
  validates_numericality_of :discount, :allow_blank => true
  
  validates_associated :product
  
  attr_accessor :should_destroy, :order_id
  
  after_save :save_product
  
  after_destroy :destroy_product
  
  def initialize(*params)
    super(*params)
    self.order_id = quote.order_id if quote
  end
  
  def after_find
    self.order_id = quote.order_id
  end
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def product_attributes=(attributes)
    if attributes[:id].blank?
      self.product = Order.find(order_id).products.build(attributes)
    else
      self.product = Order.find(order_id).products.detect{ |p| p.id == attributes[:id].to_i }
      self.product.attributes = attributes
    end
  end
  
  def save_product
    product.save(false)
  end
  
  def already_delivered_or_scheduled_quantity
    return 0 if self.new_record?
    delivery_note_items.find( :all,
                              :include    => :delivery_note,
                              :conditions => [ "delivery_notes.status IS NULL or delivery_notes.status != ?", DeliveryNote::STATUS_INVALIDATED ]
                             ).collect(&:quantity).sum
  end
  
  def remaining_quantity_to_deliver
    quantity - already_delivered_or_scheduled_quantity
  end
  
  # destroy associated product unless quote is already destroyed
  def destroy_product
    product.destroy if Quote.find_by_id(quote.id)
  end
  
  def original_name
    product ? product.product_reference.name : nil
  end
  
  def original_description
    product ? product.product_reference.description : nil
  end
  
  def original_vat
    product ? product.product_reference.vat : nil
  end
  
end
