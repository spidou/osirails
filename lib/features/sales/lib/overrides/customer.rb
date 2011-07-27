require_dependency 'lib/features/thirds/app/models/customer'

class Customer
  has_many :orders

  def terminated_orders
    ActiveSupport::Deprecation.warn("terminated_orders is now deprecated, please use order's named_scope 'closed' instead", caller)
    orders = []
    self.orders.each { |o| orders << o unless o.pending? }
    orders
  end
end
