class OrderType < ActiveRecord::Base
  has_and_belongs_to_many :society_activity_sector
end