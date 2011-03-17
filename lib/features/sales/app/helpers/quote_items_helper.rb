module QuoteItemsHelper
  
  def pro_rata_billing_text(quote_item)
    return "" unless quote_item.service_item? && quote_item.reference_object && quote_item.reference_object.pro_rata_billable?
    t('activerecord.attributes.quote_item.pro_rata_billing', :default => "Pro rata billing")
  end
  
  def display_pro_rata_billing_text(quote_item, form, options = {})
    return unless quote_item.service_item?
    
    text = pro_rata_billing_text(quote_item)
    
    if is_form_view?
      if quote_item.reference_object && quote_item.reference_object.pro_rata_billable?
        value = ( quote_item.new_record? && quote_item.pro_rata_billing.nil? ) ? quote_item.reference_object.default_pro_rata_billing? : quote_item.pro_rata_billing?
        
        html = "<br/>"
        html << form.hidden_field(:pro_rata_billing, :value => value, :class => :pro_rata_billing)
        html << check_box_tag("pro_rata_billing_#{id}", 1, value, { :onchange => "this.previous('input[type=hidden].pro_rata_billing').value = this.checked ? 1 : 0" }.merge(options[:check_box_options] || {}) )
        html << content_tag(:span, text, :onclick => "this.previous('input[type=checkbox]').click()")
      else
        form.hidden_field(:pro_rata_billing)
      end
    elsif !text.blank? and quote_item.pro_rata_billing? 
      html = "<br/>" + content_tag(:span, text, :class => :pro_rata_billing)
    end
  end
  
  def display_description_and_pro_rata_billing_for_xml(quote_item)
    text = quote_item.pro_rata_billing? ? pro_rata_billing_text(quote_item) : ""
    
    html = quote_item.description.to_s.dup # to be sure to not change the item.description at the same time
    html << "\n" unless text.blank? and html.blank?
    html << text
  end
  
end
