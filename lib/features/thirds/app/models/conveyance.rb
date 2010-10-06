class Conveyance < ActiveRecord::Base
  has_permissions :as_business_object, :additional_class_methods => [:activate, :deactivate]
  
  has_many :forwarder_conveyances
  has_many :forwarders, :through => :forwarder_conveyances
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  CONVEYANCES_PER_PAGE = 15
  
  named_scope :actives, :conditions => [ "activated = ?", true ]
  
  attr_accessor :should_destroy
  
  before_destroy :can_be_destroyed?
  
  cattr_accessor :form_labels
  @@form_labels = {}
  @@form_labels[:name]    = 'Nom :'
  @@form_labels[:activated]    = 'Activé? '
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def can_be_destroyed? 
    !new_record? and forwarders.empty?
  end
end
