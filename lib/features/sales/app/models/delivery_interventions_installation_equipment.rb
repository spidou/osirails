class DeliveryInterventionsInstallationEquipment < ActiveRecord::Base
  belongs_to :delivery_intervention
  belongs_to :installation_equipment, :class_name => 'Tool'
end
