class MemorandumsService < ActiveRecord::Base

  # Relationships
  belongs_to :memorandum
  belongs_to :service
end