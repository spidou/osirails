module DeliveryNotesHelper
  
  def display_delivery_note_add_button
    content_tag(:p, link_to("Nouveau bon de livraison", new_order_delivery_step_delivery_note_path))
  end
  
#  def order_estimate_step_quote_link_overrided(order, quote, options = {})
#    default_text = "Voir le devis#{" (PDF)" if options[:options] and options[:options][:format] == :pdf}"
#    default_image_src = ( options[:options] and options[:options][:format] == :pdf ) ? "/images/mime_type_extensions/pdf_16x16.png" : "/images/view_16x16.png"
#    
#    options = { :link_text => default_text,
#                :image_tag => image_tag(default_image_src, :alt => default_text, :title => default_text)
#              }.merge(options)
#    link_to options[:image_tag] + options[:link_text], order_estimate_step_quote_path(order, quote, options[:options] || {})
#  end
#  
#  def edit_order_estimate_step_quote_link_overrided(order, quote, options = {})
#    options = { :link_text => text = "Modifier le devis",
#                :image_tag => image_tag("/images/edit_16x16.png", :alt => text, :title => text)
#              }.merge(options)
#    link_to options[:image_tag] + options[:link_text], edit_order_estimate_step_quote_path(order, quote)
#  end
#  
#  def delete_order_estimate_step_quote_link_overrided(order, quote, options = {})
#    options = { :link_text => text = "Supprimer le devis",
#                :image_tag => image_tag("/images/delete_16x16.png", :alt => text, :title => text)
#              }.merge(options)
#    link_to options[:image_tag] + options[:link_text], order_estimate_step_quote_path(order, quote), :method => :delete, :confirm => "Are you sure?"
#  end
  
end
