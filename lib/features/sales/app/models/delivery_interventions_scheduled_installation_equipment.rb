class DeliveryInterventionsScheduledInstallationEquipment < ActiveRecord::Base
  belongs_to :delivery_intervention
  belongs_to :scheduled_installation_equipment, :class_name => 'Tool'
end
