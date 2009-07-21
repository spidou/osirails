class DeliverersIntervention < ActiveRecord::Base
  belongs_to :deliverer, :class_name => 'Employee'
  belongs_to :intervention
end
