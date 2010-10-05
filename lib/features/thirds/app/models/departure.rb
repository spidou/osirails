class Departure < ActiveRecord::Base
  has_permissions :as_business_object
  
  belongs_to :forwarder
  
  validates_presence_of :city_name, :country_name
  validates_uniqueness_of :city_name, :scope => :country_name
  validates_uniqueness_of :country_name, :scope => :city_name
  
  DEPARTURES_PER_PAGE = 15
  
  named_scope :actives, :conditions => [ "activated = ?", true ]
  
  attr_accessor :should_destroy
  
  before_destroy :can_be_destroyed?
  
  cattr_accessor :form_labels
  @@form_labels = {}
  @@form_labels[:id]            = "Point de départ :"
  @@form_labels[:city_name]     = 'Nom de la ville :'
  @@form_labels[:region_name]   = 'Nom de la région :'
  @@form_labels[:country_name]  = 'Nom du pays :'
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def can_be_destroyed?
    !new_record? and forwarders.empty?
  end
  
  def formatted
    @formatted ||= [city_name, region_name, country_name].compact.join(", ")
  end
end
