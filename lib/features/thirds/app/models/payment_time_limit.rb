class PaymentTimeLimit < ActiveRecord::Base
  # Relationships
  belongs_to :thirds

  # Validations
  validates_presence_of :name
end
