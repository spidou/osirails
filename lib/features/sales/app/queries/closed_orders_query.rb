require_dependency 'orders_query'

module ClosedOrdersQuery
  include OrdersQuery
  
  def query_td_content_for_status_since_in_order
    @query_object.status_since && l(@query_object.status_since, :format => :short)
  end
end
