class SalesProcess < ActiveRecord::Base
  # Relationships
  belongs_to :order_type
  belongs_to :step
end
