require_dependency 'society_activity_sector'
require_dependency 'customer'
require_dependency 'establishment'

class Customer
  has_many :orders

  def terminated_orders
    orders = []
    self.orders.each { |o| orders << o if o.terminated? }
    orders
  end
end

class Establishment
  has_many :orders
end

class SocietyActivitySector
  has_and_belongs_to_many :order_types
end
