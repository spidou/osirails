class ExceptionDate < ActiveRecord::Base
  # Relationships
  belongs_to :event

  # Validations
  validates_presence_of :date, :event_id
end
