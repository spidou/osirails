class DeliveryNote < ActiveRecord::Base
  has_permissions :as_business_object
  has_address     :ship_to_address
  has_contacts    :many => false,     :validates_presence => true
  
  belongs_to :creator, :class_name  => 'User', :foreign_key => 'user_id'
  belongs_to :delivery_step
  
  has_many :deliverers, :class_name => 'Employee', :foreign_key => 'employee_id'
  
  has_many :delivery_notes_quotes_product_references, :dependent => :destroy
  has_many :quotes_product_references,                :through   => :delivery_notes_quotes_product_references
  
  validates_presence_of :delivery_step, :creator, :delivery_notes_quotes_product_references
  validates_associated :delivery_notes_quotes_product_references, :quotes_product_references
  
  def signed?
    !signed_at.nil?
  end
  
  # return if there are at least one delivery_notes_quotes_product_references with a report
  def has_reports?
    #TODO
  end
end
