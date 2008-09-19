class MissingElement< ActiveRecord::Base
  # Relationships
  belongs_to :orders_steps, :class_name => "OrdersSteps"
end