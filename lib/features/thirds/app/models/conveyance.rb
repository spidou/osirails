class Conveyance < ActiveRecord::Base
  has_permissions :as_business_object
  
  has_many :forwarder_conveyances
  has_many :forwarders, :through => :forwarder_conveyances
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  named_scope :actives, :conditions => [ "activated = ?", true ]
end
