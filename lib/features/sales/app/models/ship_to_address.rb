class ShipToAddress < ActiveRecord::Base
  has_permissions :as_business_object
  has_address :address, :one_or_many => :many
  
  belongs_to :order
  belongs_to :establishment
  
  validates_presence_of :establishment_name, :address
  
  validates_associated :establishment, :address
  
  attr_accessor :should_create
  attr_accessor :should_destroy
  #attr_accessor :parallel_creation
  
  cattr_accessor :form_labels
  @@form_labels = {}
  #@@form_labels[:establishment]       = "Établissement associé :"
  @@form_labels[:establishment_name]  = "Nom de l'enseigne :" # same as Establishment#name
  
  def should_create?
    should_create.to_i == 1
  end
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def name_and_short_address
    "#{self.establishment_name} (#{self.address.street_name}, #{self.address.city_name})"
  end
end
