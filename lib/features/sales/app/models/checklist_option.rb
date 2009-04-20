class ChecklistOption < ActiveRecord::Base
  # Relationships
  belongs_to :checklist

  # Validations
  validates_presence_of :checklist_id, :name
end