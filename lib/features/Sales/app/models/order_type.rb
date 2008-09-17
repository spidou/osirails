class OrderType < ActiveRecord::Base
  # Relationships
  has_and_belongs_to_many :society_activity_sectors
  has_many :sales_processus
end