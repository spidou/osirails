module QuotesHelper
  
  def display_quote_add_button
    content_tag(:p, link_to("Nouveau devis", new_order_step_estimate_quote_path))
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
