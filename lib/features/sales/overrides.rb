SocietyActivitySector.module_eval do 
  has_and_belongs_to_many :order_types
end

Customer.module_eval do 
  has_many :orders
end

class Customer
  def terminated_orders
    orders = []
    self.orders.each { |o| orders << o if o.terminated? }
    orders
  end
end

Establishment.module_eval do 
  has_many :orders
end