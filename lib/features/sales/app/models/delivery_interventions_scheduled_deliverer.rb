class DeliveryInterventionsScheduledDeliverer < ActiveRecord::Base
  belongs_to :delivery_intervention
  belongs_to :scheduled_deliverer, :class_name => 'Employee'
end
