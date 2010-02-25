class DeliveryInterventionsDeliverer < ActiveRecord::Base
  belongs_to :delivery_intervention
  belongs_to :deliverer, :class_name => 'Employee'
end
