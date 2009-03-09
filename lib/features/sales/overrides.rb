require_dependency 'customer'

class Customer
  has_many :orders
  
  def terminated_orders
    orders = []
    self.orders.each { |o| orders << o if o.terminated? }
    orders
  end
end

require_dependency 'establishment'

class Establishment
  has_many :orders
end

require_dependency 'society_activity_sector'

class SocietyActivitySector
  has_and_belongs_to_many :order_types
end
