class Checklist < ActiveRecord::Base
  # Relationships
  has_many :checklist_options
  belongs_to :step
end