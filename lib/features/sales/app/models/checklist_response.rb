class ChecklistResponse < ActiveRecord::Base
  # Relationships
  belongs_to :orders_steps, :class_name => "OrdersSteps"
  belongs_to :checklist
end