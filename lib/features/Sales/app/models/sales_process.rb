class SalesProcess < ActiveRecord::Base
  # Relationships
  belongs_to :order_type
  has_and_belongs_to_many :steps
end
