require_dependency 'app/models/society_activity_sector'

class SocietyActivitySector
  has_and_belongs_to_many :order_types
end
