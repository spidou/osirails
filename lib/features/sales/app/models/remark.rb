class Remark < ActiveRecord::Base
  # Relationships
  belongs_to :user

  # Validations
  validates_presence_of :user_id
end