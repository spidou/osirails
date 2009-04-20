class MissingElement< ActiveRecord::Base
  # Relationships
  belongs_to :orders_steps, :class_name => "OrdersSteps"

  # Validations
  validates_presence_of :name, :orders_steps_id
end