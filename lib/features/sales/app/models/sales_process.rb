class SalesProcess < ActiveRecord::Base
  # Relationships
  belongs_to :order_type
  belongs_to :step

  # Validations
  validates_presence_of :order_type_id, :step_id
end
