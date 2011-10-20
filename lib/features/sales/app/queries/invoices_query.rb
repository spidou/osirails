module InvoicesQuery
  def query_tr_in_invoice(content)
    content_tag(:tr, content, :class => @html_class, 'data-invoice-status' => @query_object.status, 'data-invoice-priority' => @query_object.priority_level)
  end
  
  def query_td_content_for_order_reference_in_invoice
    link_to(@query_object.order.reference, @query_object.order)
  end
  
  def query_td_content_for_order_title_in_invoice
    link_to(@query_object.order.title.shorten(25, "[...]"), @query_object.order, :title => @query_object.order.title)
  end
  
  def query_td_for_order_title_in_invoice(content)
    content_tag(:td, content, :class => :text)
  end
  
  def query_td_content_for_order_customer_name_in_invoice
    link_to(@query_object.order.customer.name.shorten(30, "[...]"), @query_object.order.customer, :title => @query_object.order.customer.name)
  end
  
  def query_td_for_order_customer_name_in_invoice(content)
    content_tag(:td, content, :class => :text)
  end
  
  def query_td_content_for_reference_in_invoice
    link_to(@query_object.reference_or_id, order_invoicing_step_invoice_step_invoice_path(@query_object.order, @query_object))
  end
  
  def query_td_content_for_published_on_in_invoice
    l(@query_object.published_on, :format => :short) if @query_object.published_on
  end
  
  def query_td_content_for_sended_on_in_invoice
    l(@query_object.sended_on, :format => :short) if @query_object.sended_on
  end
  
  def query_td_content_for_net_to_paid_in_invoice
    @query_object.net_to_paid.to_f.round_to(2).to_s(2) + "&nbsp;&euro;"
  end
  
  def query_td_for_net_to_paid_in_invoice(content)
    content_tag(:td, content, :class => :amount)
  end
  
  def query_td_content_for_already_paid_amount_in_invoice
    @query_object.already_paid_amount.to_f.round_to(2).to_s(2) + "&nbsp;&euro;"
  end
  
  def query_td_for_already_paid_amount_in_invoice(content)
    content_tag(:td, content, :class => :amount)
  end
  
  def query_td_content_for_global_granted_delay_in_invoice
    "#{@query_object.global_granted_delay}&nbsp;j" if @query_object.global_granted_delay
  end
  
  def query_th_content_for_upcoming_due_date_in_invoice(column, order)
    date_column = "#{column}_date"
    amount_column = "#{column}_amount"
    
    date_content = humanize(date_column)
    amount_content = humanize(amount_column)
    
    content = "#{humanize(column)}<br/>"
    
    content += if with_sort?(date_column, order)
      sort_link(date_content, get_direction_img(date_column, order), date_column, order)
    elsif sortable?(date_column)
      sort_link(date_content, nil, date_column, order)
    else
      date_content
    end
    
    content += " | "
    
    content += if with_sort?(amount_column, order)
      sort_link(amount_content, get_direction_img(amount_column, order), amount_column, order)
    elsif sortable?(amount_column)
      sort_link(amount_content, nil, amount_column, order)
    else
      amount_content
    end
    
    content
  end
  
  def query_th_for_upcoming_due_date_in_invoice(content)
    content_tag(:th, content, :colspan => 2)
  end
  
  def query_td_for_upcoming_due_date_in_invoice(content)
    date = nil
    amount = nil
    
    if due_date = @query_object.upcoming_due_date
      date = l(@query_object.upcoming_due_date.date, :format => :short) + display_delay_of_upcoming_due_date_paiment_for(@query_object)
      amount = "#{@query_object.upcoming_due_date.net_to_paid}&nbsp;&euro;"
    end
    
    content_tag(:td, date, 'data-attribute' => :upcoming_due_date_date) +
    content_tag(:td, amount, 'data-attribute' => :upcoming_due_date_net_to_paid, :class => :amount)
  end
  
  def query_td_content_for_delivery_notes_in_invoice
    @query_object.delivery_notes.collect do |dn|
      link_to(dn.reference, order_delivering_step_delivery_step_delivery_note_path(@query_object.order, dn))
    end.join("<br/>")
  end
  
  def query_td_content_for_status_in_invoice
    invoice_status_text(@query_object)
  end
  
  def query_td_content_for_abandoned_comment_in_invoice
    content_tag(:span, @query_object.abandoned_comment.shorten(35, "[...]"), :title => @query_object.abandoned_comment) unless @query_object.abandoned_comment.blank?
  end
  
  def query_td_content_for_cancelled_at_in_invoice
    l(@query_object.cancelled_at.to_date, :format => :short) if @query_object.cancelled_at
  end
  
  def query_td_content_for_cancelled_comment_in_invoice
    content_tag(:span, @query_object.cancelled_comment.shorten(35, "[...]"), :title => @query_object.cancelled_comment) unless @query_object.cancelled_comment.blank?
  end
end
