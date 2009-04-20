class StepInvoicing < ActiveRecord::Base
  # Relationships
  belongs_to :order

  # Validations
  validates_presence_of :order_id

  # Plugins
  acts_as_step
end