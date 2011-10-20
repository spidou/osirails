module QuotesQuery
  def query_tr_in_quote(content)
    content_tag(:tr, content, :class => @html_class, 'data-quote-status' => @query_object.status, 'data-quote-priority' => @query_object.priority_level)
  end
  
  def query_td_content_for_order_reference_in_quote
    link_to(@query_object.order.reference, @query_object.order)
  end
  
  def query_td_content_for_order_title_in_quote
    link_to(@query_object.order.title.shorten(25, "[...]"), @query_object.order, :title => @query_object.order.title)
  end
  
  def query_td_for_order_title_in_quote(content)
    content_tag(:td, content, :class => :text)
  end
  
  def query_td_content_for_order_customer_name_in_quote
    link_to(@query_object.order.customer.name.shorten(30, "[...]"), @query_object.order.customer, :title => @query_object.order.customer.name)
  end
  
  def query_td_for_order_customer_name_in_quote(content)
    content_tag(:td, content, :class => :text)
  end
  
  def query_td_content_for_reference_in_quote
    link_to(@query_object.reference_or_id, order_commercial_step_quote_step_quote_path(@query_object.order, @query_object))
  end
  
  def query_td_content_for_published_on_in_quote
    l(@query_object.published_on, :format => :short) if @query_object.published_on
  end
  
  def query_td_content_for_sended_on_in_quote
    l(@query_object.sended_on, :format => :short) if @query_object.sended_on
  end
  
  def query_td_content_for_signed_on_in_quote
    l(@query_object.signed_on, :format => :short) if @query_object.signed_on
  end
  
  def query_td_content_for_cancelled_at_in_quote
    l(@query_object.cancelled_at.to_date, :format => :short) if @query_object.cancelled_at
  end
  
  def query_td_content_for_validity_date_in_quote
    l(@query_object.validity_date, :format => :short) if @query_object.validity_date
  end
  
  def query_td_content_for_validity_delay_in_quote
    display_validity_delay_and_unit_for(@query_object) if @query_object.validity_delay and @query_object.validity_delay_unit
  end
  
  def query_td_content_for_total_with_taxes_in_quote
    @query_object.total_with_taxes.to_f.round_to(2).to_s(2) + "&nbsp;&euro;"
  end
  
  def query_td_for_total_with_taxes_in_quote(content)
    content_tag(:td, content, :class => :amount)
  end
  
  def query_td_content_for_deposit_in_quote
    @query_object.deposit.to_f.round_to(2).to_s(2) + "&nbsp;%" unless @query_object.deposit.blank?
  end
  
  def query_td_for_deposit_in_quote(content)
    content_tag(:td, content, :class => :amount)
  end
  
  def query_td_content_for_order_quotation_deadline_in_quote
    l(@query_object.order.quotation_deadline, :format => :short) if @query_object.order.quotation_deadline
  end
  
  def query_td_content_for_status_in_quote
    quote_status_text(@query_object)
  end
end
