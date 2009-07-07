class DeliveryStep < ActiveRecord::Base
  acts_as_step
  
  has_many :delivery_notes
end
