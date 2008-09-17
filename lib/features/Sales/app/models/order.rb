class Order < ActiveRecord::Base
  # Relationships
  belongs_to :society_activity_sector
  belongs_to :order_type
  has_one :commercial_order
  has_one :facturation_order
  has_one :production_order
  has_and_belongs_to_many :steps
end