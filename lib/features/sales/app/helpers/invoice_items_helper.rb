module InvoiceItemsHelper
  
  def display_pro_rata_billing_text(invoice_item)
    return unless invoice_item.service_item? and invoice_item.invoiceable.pro_rata_billing?
    
    text = t('activerecord.attributes.invoice_item.pro_rata_billing', :default => "Pro rata billing")
    html = "<br/>" + content_tag(:span, text, :class => :pro_rata_billing)
  end
  
end
