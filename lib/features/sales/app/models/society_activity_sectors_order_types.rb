class SocietyActivitySectorsOrderTypes < ActiveRecord::Base
  # Relationships
  belongs_to :society_activity_sector
  belongs_to :order_type
end
