class DeliveryStep < ActiveRecord::Base
  has_permissions :as_business_object
  acts_as_step
  
  has_many :delivery_notes
  
  has_one  :uncomplete_delivery_note, :class_name => 'DeliveryNote', :conditions => [ 'status IS NULL' ]
  has_many :signed_delivery_notes,    :class_name => 'DeliveryNote', :conditions => [ "status = ?", DeliveryNote::STATUS_SIGNED ]
end
