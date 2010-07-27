class MissingElement< ActiveRecord::Base
  belongs_to :orders_steps, :class_name => "OrdersSteps"
  validates_presence_of :name, :orders_steps_id
end
