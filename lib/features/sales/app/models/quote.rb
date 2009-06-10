class Quote < ActiveRecord::Base
  has_permissions :as_business_object
  has_address     :bill_to_address
  has_address     :ship_to_address
  has_contacts    :many => false,     :validates_presence => true
  
  belongs_to :creator,       :class_name  => 'User',                  :foreign_key => 'user_id'
  belongs_to :estimate_step
  
  has_many :quotes_product_references, :dependent => :destroy
  has_many :product_references,        :through   => :quotes_product_references
  
  validates_presence_of :estimate_step, :reduction, :carriage_costs, :account, :creator, :quotes_product_references
  validates_numericality_of [:reduction, :carriage_costs, :account], :allow_nil => false
  validates_associated :quotes_product_references, :product_references
  
  after_update :save_quotes_product_references
  
  def quotes_product_reference_attributes=(quotes_product_reference_attributes)
    quotes_product_reference_attributes.each do |attributes|
      unless attributes[:product_reference_id].blank?
        if attributes[:id].blank?
          product_reference = ProductReference.find(attributes[:product_reference_id])
          
          quotes_product_reference = quotes_product_references.build(attributes)
          
          # original_name, original_description and original_unit_price are protected form mass-assignment !
          quotes_product_reference.update_attribute(:original_name, product_reference.name)
          quotes_product_reference.update_attribute(:original_description, product_reference.description)
          quotes_product_reference.update_attribute(:original_unit_price, product_reference.unit_price)
        else
          quotes_product_reference = quotes_product_references.detect { |x| x.id == attributes[:id].to_i }
          quotes_product_reference.attributes = attributes
        end
      end
    end
  end
  
  def save_quotes_product_references
    quotes_product_references.each do |x|
      if x.should_destroy?
        x.destroy
      else
        x.save(false)
      end
    end
  end
  
  def total
    quotes_product_references.collect{ |qpr| qpr.total }.sum
  end
  
  def net
    total - reduction + carriage_costs
  end
  
  def total_with_taxes
    quotes_product_references.collect{ |qpr| qpr.total_with_taxes }.sum
  end
  
  def summon_of_taxes
    total_with_taxes - total
  end
  
  def net_to_paid
    total_with_taxes - account
  end
  
  def validated?
    validated
  end
  
  def number_of_pieces
    quotes_product_references.collect{ |qpr| qpr.quantity }.sum
  end
end
