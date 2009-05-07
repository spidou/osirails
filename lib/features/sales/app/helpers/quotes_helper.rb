module QuotesHelper
  
  def display_quotes_list(step)
    quotes = step.quotes
    html = "<table>"
    html << "<tr>"
    html << content_tag(:th, "Date")
    html << content_tag(:th, "Nb Pièces")
    html << content_tag(:th, "Total Net TTC")
    html << content_tag(:th, "Créateur du devis")
    html << content_tag(:th, "Envoyé au client ?")
    html << content_tag(:th, "Actions")
    html << "</tr>"
    
    html << render(:partial => 'quotes/quote_in_one_line', :collection => quotes)
    
    html << "</table>"
  end
  
  def display_quote_add_button
    html = "<p>"
    html << link_to("Nouveau devis", new_order_step_estimate_quote_path)
    html << "</p>"
  end
  
  def order_step_estimate_quote_link_overrided(order, quote, options = {})
    options = { :link_text => text = "Voir le devis (PDF)",
                :image_tag => image_tag("/images/mime_type_extensions/pdf_16x16.png", :alt => text, :title => text)
              }.merge(options)
    link_to options[:image_tag] + options[:link_text], order_step_estimate_quote_path(order, quote, options[:options] || {})
  end
  
  def edit_order_step_estimate_quote_link_overrided(order, quote, options = {})
    options = { :link_text => text = "Modifier le devis",
                :image_tag => image_tag("/images/edit_16x16.png", :alt => text, :title => text)
              }.merge(options)
    link_to options[:image_tag] + options[:link_text], edit_order_step_estimate_quote_path(order, quote)
  end
  
  def delete_order_step_estimate_quote_link_overrided(order, quote, options = {})
    options = { :link_text => text = "Supprimer le devis",
                :image_tag => image_tag("/images/delete_16x16.png", :alt => text, :title => text)
              }.merge(options)
    link_to options[:image_tag] + options[:link_text], order_step_estimate_quote_path(order, quote), :method => :delete, :confirm => "Are you sure?"
  end
  
end
