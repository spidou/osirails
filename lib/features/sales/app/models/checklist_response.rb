class ChecklistResponse < ActiveRecord::Base
  # Relationships
  belongs_to :checklist

  # Validations
  validates_presence_of :checklist_id, :has_checklist_response_id, :has_checklist_response_type
end