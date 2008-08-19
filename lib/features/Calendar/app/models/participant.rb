class Participant < ActiveRecord::Base
  # Relationships
  belongs_to :event
end
