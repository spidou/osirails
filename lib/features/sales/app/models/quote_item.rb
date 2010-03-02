class QuoteItem < ActiveRecord::Base
  include ProductBase
  
  belongs_to :quote
  belongs_to :product
  
  acts_as_list :scope => :quote
  
  has_many :delivery_note_items, :dependent => :nullify
  has_many :delivery_notes,      :through   => :delivery_note_items
  
  validates_presence_of :name, :description, :dimensions
  
  validates_numericality_of :unit_price, :vat, :quantity
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
    self.product_reference_id = product.product_reference_id if product
  end

  def after_find
    self.order_id = quote.order_id
    self.product_reference_id = product.product_reference_id if product
  end
  
  def order
    Order.find_by_id(order_id)
  end
  
  def build_or_update_product
    return unless product_reference_id or product
    
    self.product ||= order.products.build(:product_reference_id => product_reference_id)
    
    [:name, :description, :dimensions, :unit_price, :prizegiving, :quantity, :vat, :position].each do |attribute|
      product.send("#{attribute}=", self.send(attribute))
    end
  end
  
  def save_product
    product.save(false) if product
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
    product.destroy if product and Quote.find_by_id(quote.id)
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
