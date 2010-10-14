class Departure < ActiveRecord::Base
  has_permissions :as_business_object, :additional_class_methods => [ :hide ]
  
  belongs_to :forwarder
  
  validates_presence_of   :city_name, :country_name
  validates_uniqueness_of :city_name, :scope => [:country_name, :forwarder_id]
  validates_uniqueness_of :country_name, :scope => [:city_name, :forwarder_id]
  
  named_scope :actives, :conditions => [ "activated = ?", true ]
  
  attr_accessor :should_destroy
  attr_accessor :should_hide
  attr_accessor :should_update
  
  before_destroy :can_be_destroyed?
  
  cattr_accessor :form_labels
  @@form_labels = {}
  @@form_labels[:id]            = "Point de départ :"
  @@form_labels[:city_name]     = 'Nom de la ville :'
  @@form_labels[:region_name]   = 'Nom de la région :'
  @@form_labels[:country_name]  = 'Nom du pays :'
  
  def can_be_hidden?
    !new_record?
  end
  
  def can_be_destroyed?
    !new_record? #and !forwarder.quotation
  end
  
  def hide
    if can_be_hidden?
      self.hidden = true 
      self.save
    end
  end
  
  def should_hide?
    should_hide.to_i == 1
  end
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def should_update?
    should_update.to_i == 1
  end
  
  def formatted
    @formatted ||= [city_name, (region_name == "" ? nil : region_name ), country_name].compact.join(", ")
  end
end
