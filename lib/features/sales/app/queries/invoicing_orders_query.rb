require_dependency 'orders_query'

module InvoicingOrdersQuery
  include OrdersQuery
  
  def query_td_content_for_billable_amount_in_order
    if @query_object.signed_quote
      @query_object.billable_amount.to_f.round_to(2).to_s(2) + "&nbsp;&euro;"
    end
  end
  
  def query_td_for_billable_amount_in_order(content)
    content_tag :td, content, :class => :amount
  end
  
  def query_td_content_for_billed_amount_in_order
    if @query_object.signed_quote
      link_to(@query_object.billed_amount.to_f.round_to(2).to_s(2) + "&nbsp;&euro;", order_invoicing_step_invoice_step_path(@query_object), :title => "Aller à l'étape Facturation")
    end
  end
  
  def query_td_for_billed_amount_in_order(content)
    content_tag :td, content, :class => :amount
  end
  
  def query_td_content_for_unbilled_amount_in_order
    if @query_object.signed_quote
      amount = @query_object.unbilled_amount || 0
      link_to(amount.to_f.round_to(2).to_s(2) + "&nbsp;&euro;", order_invoicing_step_invoice_step_path(@query_object), :title => "Aller à l'étape Facturation")
    end
  end
  
  def query_td_for_unbilled_amount_in_order(content)
    content_tag :td, content, :class => :amount
  end
  
  def query_td_content_for_paid_amount_in_order
    if @query_object.signed_quote
      link_to(@query_object.paid_amount.to_f.round_to(2).to_s(2) + "&nbsp;&euro;", order_invoicing_step_invoice_step_path(@query_object), :title => "Aller à l'étape Facturation")
    end
  end
  
  def query_td_for_paid_amount_in_order(content)
    content_tag :td, content, :class => :amount
  end
  
  def query_td_content_for_unpaid_amount_in_order
    if @query_object.signed_quote
      amount = @query_object.unpaid_amount || 0
      link_to(amount.to_f.round_to(2).to_s(2) + "&nbsp;&euro;", order_invoicing_step_invoice_step_path(@query_object), :title => "Aller à l'étape Facturation")
    end
  end
  
  def query_td_for_unpaid_amount_in_order(content)
    content_tag :td, content, :class => :amount
  end
end
