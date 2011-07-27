module OrdersQuery
  def query_td_content_for_reference_in_order
    link_to(@query_object.reference, @query_object)
  end
  
  def query_td_content_for_title_in_order
    link_to(@query_object.title.shorten(25, "[...]"), @query_object, :title => @query_object.title)
  end
  
  def query_td_for_title_in_order(content)
    content_tag(:td, content, :class => :text)
  end
  
  def query_td_content_for_customer_name_in_order
    link_to(@query_object.customer.name.shorten(30, "[...]"), @query_object.customer, :title => @query_object.customer.name)
  end
  
  def query_td_for_customer_name_in_order(content)
    content_tag(:td, content, :class => :text)
  end
  
  def query_td_for_brand_names_in_order(content)
    content_tag(:td, content, :class => :text)
  end
  
  def query_td_for_commercial_fullname_in_order(content)
    content_tag(:td, content, :class => :text)
  end
  
  def query_td_for_previsional_delivery_in_order(content)
    content_tag(:td, content, :class => :text)
  end
  
  def query_td_content_for_previsional_delivery_in_order
    l(@query_object.previsional_delivery, :format => :short) + " (#{remaining_days_before_delivery(@query_object)})"
  end
  
  def query_td_content_for_amount_in_order
    return unless @query_object.amount
    html = ""
    html << "~&nbsp;" unless @query_object.signed_quote
    html << @query_object.amount.to_f.round_to(2).to_s(2) + "&nbsp;&euro;"
  end
  
  def query_td_for_amount_in_order(content)
    content_tag :td, content, :class => :amount
  end
  
  def query_td_content_for_signed_quote_status_in_order
    if @query_object.signed_quote
      link_to(t("view.signed_quote.statuses.signed", :default => 'signed').gsub(' ', '&nbsp;'), order_commercial_step_quote_step_quote_order_form_path(@query_object, @query_object.signed_quote), :class => "quote_status signed", :title => "Télécharger le devis signé")
    else
      link_to(t("view.signed_quote.statuses.unsigned", :default => 'unsigned').gsub(' ', '&nbsp;'), order_commercial_step_quote_step_path(@query_object), :class => "quote_status unsigned", :title => "Aller à l'étape Devis")
    end
  end
  
  def query_td_content_for_deposit_invoice_status_in_order
    if @query_object.signed_quote
      if @query_object.deposit_required?
        if (status = @query_object.deposit_invoice_status) && (status == Invoice::STATUS_TOTALLY_PAID)
          class_name = 'paid'
          value = 'Payé'
        else
          class_name = 'unpaid'
          value = 'Non payé'
        end
      else
        class_name = 'not_required'
        value = 'Non demandé'
      end
      
      link_to(value.gsub(' ', '&nbsp;'), order_invoicing_step_invoice_step_path(@query_object), :class => "deposit #{class_name}")
    end
  end
  
  def query_td_content_for_status_in_order
    content_tag :span, t("view.order.statuses.#{@query_object.status}", :default => @query_object.status).gsub(' ', '&nbsp;'), :class => "order_status #{@query_object.status}"
  end
  
  def query_td_content_for_commercial_step_survey_step_status_in_order
    display_step_status(@query_object.commercial_step.survey_step)
  end
  
  def query_td_content_for_commercial_step_quote_step_status_in_order
    display_step_status(@query_object.commercial_step.quote_step)
  end
  
  def query_td_content_for_commercial_step_press_proof_step_status_in_order
    display_step_status(@query_object.commercial_step.press_proof_step)
  end
  
  def query_td_content_for_production_step_manufacturing_step_status_in_order
    display_step_status(@query_object.production_step.manufacturing_step)
  end
  
  def query_td_content_for_delivering_step_delivery_step_status_in_order
    display_step_status(@query_object.delivering_step.delivery_step)
  end
  
  def query_td_content_for_invoicing_step_invoice_step_status_in_order
    display_step_status(@query_object.invoicing_step.invoice_step)
  end
  
  def query_td_content_for_invoicing_step_payment_step_status_in_order
    display_step_status(@query_object.invoicing_step.payment_step)
  end
  
  private
    def display_step_status(step)
      link_to(t("view.step.statuses.#{step.status}", :default => step.status).gsub(' ', '&nbsp;'), send(step.original_step.path, step.order), :class => "step_status #{step.status}", :title => "Aller à l'étape")
    end
end
