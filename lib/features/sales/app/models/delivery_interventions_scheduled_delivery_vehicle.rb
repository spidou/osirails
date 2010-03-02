class DeliveryInterventionsScheduledDeliveryVehicle < ActiveRecord::Base
  belongs_to :delivery_intervention
  belongs_to :scheduled_delivery_vehicle, :class_name => 'Vehicle'
end
