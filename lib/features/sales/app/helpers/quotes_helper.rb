module QuotesHelper
  
  def display_quote_add_button
    content_tag(:p, link_to("Nouveau devis", new_order_commercial_step_estimate_step_quote_path))
  end
  
  def order_commercial_step_estimate_step_quote_link_overrided(order, quote, options = {})
    default_text = "Voir le devis#{" (PDF)" if options[:options] and options[:options][:format] == :pdf}"
    default_image_src = ( options[:options] and options[:options][:format] == :pdf ) ? "/images/mime_type_extensions/pdf_16x16.png" : "/images/view_16x16.png"
    
    options = { :link_text => default_text,
                :image_tag => image_tag(default_image_src, :alt => default_text, :title => default_text)
              }.merge(options)
    link_to options[:image_tag] + options[:link_text], order_commercial_step_estimate_step_quote_path(order, quote, options[:options] || {})
  end
  
  def edit_order_commercial_step_estimate_step_quote_link_overrided(order, quote, options = {})
    options = { :link_text => text = "Modifier le devis",
                :image_tag => image_tag("/images/edit_16x16.png", :alt => text, :title => text)
              }.merge(options)
    link_to options[:image_tag] + options[:link_text], edit_order_commercial_step_estimate_step_quote_path(order, quote)
  end
  
  def delete_order_commercial_step_estimate_step_quote_link_overrided(order, quote, options = {})
    options = { :link_text => text = "Supprimer le devis",
                :image_tag => image_tag("/images/delete_16x16.png", :alt => text, :title => text)
              }.merge(options)
    link_to options[:image_tag] + options[:link_text], order_commercial_step_estimate_step_quote_path(order, quote), :method => :delete, :confirm => "Are you sure?"
  end
  
  def display_additional_actions_quote_button(order, quote)
    html =  display_validate_quote_button(order, quote) || ""
    html << ( display_send_quote_button(order, quote) || "" )
    html << ( display_sign_quote_button(order, quote) || "" )
    html << ( display_order_form_quote_button(order, quote) || "" )
  end
  
  def display_validate_quote_button(order, quote)
    if Quote.can_edit?(current_user)
      if quote.can_be_invalidated?
        link_to( image_tag( "/images/#{Quote::STATUS_INVALIDATED}_16x16.png",
                            :alt => text = "Invalider ce devis",
                            :title => text ),
                 order_commercial_step_estimate_step_quote_invalidate_path(order, quote),
                 :confirm => "Êtes-vous sûr ?" )
      
      elsif quote.can_be_validated?
        link_to( image_tag( "/images/#{Quote::STATUS_VALIDATED}_16x16.png",
                            :alt => text = "Valider ce devis",
                            :title => text ),
                 order_commercial_step_estimate_step_quote_validate_path(order, quote),
                 :confirm => "Êtes-vous sûr ?\nCeci aura pour conséquence de générer un numéro unique pour le devis et vous ne pourrez plus le modifier." )
      end
    end
  end
  
  def display_send_quote_button(order, quote)
    if Quote.can_edit?(current_user) and quote.can_be_sended?        
      link_to( image_tag( "/images/#{Quote::STATUS_SENDED}_16x16.png",
                          :alt => text = "Signaler que le devis a été envoyé au client",
                          :title => text ),
               order_commercial_step_estimate_step_quote_send_form_path(order, quote) )
    end
  end
  
  def display_sign_quote_button(order, quote)
    if Quote.can_edit?(current_user) and quote.can_be_signed?        
      link_to( image_tag( "/images/#{Quote::STATUS_SIGNED}_16x16.png",
                          :alt => text = "Signaler que le devis a été signé par le client",
                          :title => text ),
               order_commercial_step_estimate_step_quote_sign_form_path(order, quote) )
    end
  end
  
  def display_order_form_quote_button(order, quote)
    if Quote.can_view?(current_user) and quote.signed? and quote.order_form
      link_to( image_tag( "/images/mime_type_extensions/pdf_16x16.png",
                          :alt => text = "Voir le #{quote.order_form_type.name}",
                          :title => text ),
               order_commercial_step_estimate_step_quote_order_form_path(order, quote) )
    end
  end
  
end
