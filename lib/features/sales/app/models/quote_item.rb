class QuoteItem < ActiveRecord::Base
  include ProductBase
  
  belongs_to :quote
  belongs_to :product
  
  has_many :delivery_note_items, :dependent => :nullify
  has_many :delivery_notes,      :through   => :delivery_note_items
  
  validates_presence_of :name
  
  validates_numericality_of :unit_price, :vat, :quantity, :unless => :free_item?
  validates_numericality_of :prizegiving, :allow_blank => true
  
  validates_associated :product
  
  attr_accessor :should_destroy, :product_reference_id, :order_id
  
  before_validation :build_or_update_product
  
  after_save :save_product
  
  after_destroy :destroy_product
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def initialize(*params)
    super(*params)
    self.order_id = quote.order_id if quote
    self.product_reference_id = product.product_reference_id unless free_item?
  end

  def after_find
    self.order_id = quote.order_id
    self.product_reference_id = product.product_reference_id unless free_item?
  end
  
  def order
    Order.find_by_id(order_id)
  end
  
  def free_item?
    product.nil?
  end
  
  def build_or_update_product
    return if product_reference_id.blank? and free_item?
    
    self.product ||= order.products.build(:product_reference_id => product_reference_id)
    
    [:name, :description, :dimensions, :unit_price, :prizegiving, :quantity, :vat, :position].each do |attribute|
      product.send("#{attribute}=", self.send(attribute))
    end
  end
  
  def save_product
    product.save(false) unless free_item?
  end
  
  def already_delivered_or_scheduled_quantity
    return 0 if self.new_record? or delivery_note_items.empty?
    #OPTIMIZE how can I replace that find method by a call to the named_scope ':actives' in delivery_note.rb (conditions are the same)
    delivery_note_items.find( :all,
                              :include    => :delivery_note,
                              :conditions => [ "delivery_notes.status IS NULL or delivery_notes.status != ?", DeliveryNote::STATUS_CANCELLED ]
                             ).collect(&:really_delivered_quantity).sum
  end
  
  def remaining_quantity_to_deliver
    ( quantity || 0 ) - already_delivered_or_scheduled_quantity
  end
  
  # destroy associated product unless quote is already destroyed (to avoid to destroy all products when we destroying a quote)
  def destroy_product
    product.destroy if !free_item? and Quote.find_by_id(quote.id)
  end
  
  def original_name
    free_item? ? nil : product.product_reference.name
  end
  
  def original_description
    free_item? ? nil : product.product_reference.description
  end
  
  def original_vat
    free_item? ? nil : product.product_reference.vat
  end
  
  def designation
    free_item? ? name : product.designation
  end
  
  def position # used for sorted_quote_items
    super || 0
  end
  
end
