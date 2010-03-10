class DeliveryInterventionsDeliveryVehicle < ActiveRecord::Base
  belongs_to :delivery_intervention
  belongs_to :delivery_vehicle, :class_name => 'Vehicle'
end
