require_dependency 'orders_query'
require_dependency 'invoicing_orders_query'

module PreInvoicingOrdersQuery
  include OrdersQuery
  include InvoicingOrdersQuery
end
