class ChecklistResponse < ActiveRecord::Base
  # Relationships
  belongs_to :order_step
end