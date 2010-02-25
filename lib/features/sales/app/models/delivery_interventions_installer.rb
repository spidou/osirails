class DeliveryInterventionsInstaller < ActiveRecord::Base
  belongs_to :delivery_intervention
  belongs_to :installer, :class_name => 'Employee'
end
