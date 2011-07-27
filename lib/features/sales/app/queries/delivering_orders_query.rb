require_dependency 'orders_query'
require_dependency 'production_orders_query'

module DeliveringOrdersQuery
  include OrdersQuery
  include ProductionOrdersQuery
end
