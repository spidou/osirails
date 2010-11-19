class QuoteItem < ActiveRecord::Base
  include ProductBase
  
  belongs_to :quote
  belongs_to :end_product
  
  validates_presence_of :name
  
  validates_numericality_of :unit_price, :vat, :quantity, :unless => :free_item?
  validates_numericality_of :prizegiving, :allow_blank => true
  
  validates_associated :end_product
  
  journalize :identifier_method => :name, :attributes => [ :name, :description, :end_product_id, :dimensions, :quantity, :unit_price, :vat, :prizegiving ]
  
  attr_accessor :should_destroy, :product_reference_id, :order_id
  
  before_validation :build_or_update_end_product
  
  after_save :save_end_product
  
  after_destroy :destroy_end_product
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def initialize(*params)
    super(*params)
    self.order_id = quote.order_id if quote
    self.product_reference_id = end_product.product_reference_id if product_reference_id.blank? and end_product
  end

  def after_find
    self.order_id = quote.order_id if quote # `if quote` added to avoid raise on quote_item_ids call, see next link for further explanations: http://github.com/rails/rails/commit/b163d83b8bab9103dc0e73b86212c2629cb45ca2
    self.product_reference_id = end_product.product_reference_id if product_reference_id.blank? and end_product
  end
  
  def product_reference
    ProductReference.find_by_id(product_reference_id)
  end
  
  def order
    Order.find_by_id(order_id)
  end
  
  def free_item?
    end_product.nil? and product_reference_id.blank?
  end
  
  def build_or_update_end_product
    return if free_item?
    
    self.end_product ||= order.end_products.build(:product_reference_id => product_reference_id)
    
    %w( name description dimensions unit_price prizegiving quantity vat position ).each do |attr|
      end_product.send("#{attr}=", self.send(attr))
    end
  end
  
  def save_end_product
    end_product.save(false) unless free_item?
  end
  
  # destroy associated end_product unless quote is already destroyed (to avoid to destroy all end_products when we destroying a quote)
  def destroy_end_product
    end_product.destroy if !free_item? and Quote.find_by_id(quote.id)
  end
  
  def name
    self[:name] ||= product_reference && product_reference.designation
  end
  
  def description
    self[:description] ||= product_reference && product_reference.description
  end
  
  def vat
    self[:vat] ||= product_reference && product_reference.vat
  end
  
  def original_name
    free_item? ? nil : product_reference && product_reference.designation
  end
  
  def original_description
    free_item? ? nil : product_reference && product_reference.description
  end
  
  def original_vat
    free_item? ? nil : product_reference && product_reference.vat
  end
  
  def designation
    free_item? ? name : name + ( dimensions.blank? ? "" : " (#{dimensions})" )
  end
  
  def position # used by Quote#sorted_quote_items
    super || 0
  end
  
end
