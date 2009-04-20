class MemorandumsService < ActiveRecord::Base
  # Relationships
  belongs_to :memorandum
  belongs_to :service

  # Validations
  validates_presence_of :memorandum_id, :service_id
end