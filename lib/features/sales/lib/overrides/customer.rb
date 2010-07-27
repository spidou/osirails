require_dependency 'lib/features/thirds/app/models/customer'

class Customer
  has_many :orders

  def terminated_orders
    orders = []
    self.orders.each { |o| orders << o if o.terminated? }
    orders
  end
end
