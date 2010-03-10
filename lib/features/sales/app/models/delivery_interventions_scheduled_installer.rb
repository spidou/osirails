class DeliveryInterventionsScheduledInstaller < ActiveRecord::Base
  belongs_to :delivery_intervention
  belongs_to :scheduled_installer, :class_name => 'Employee'
end
