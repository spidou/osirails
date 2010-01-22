module QuotesHelper
  
  def display_quote_add_link(order)
    return unless Quote.can_add?(current_user) and order.quotes.build.can_be_added?
    content_tag(:p, new_order_commercial_step_estimate_step_quote_link_overrided(order, :image_tag => nil))
  end
  
  def new_order_commercial_step_estimate_step_quote_link_overrided(order, options = {})
    return unless Quote.can_add?(current_user)
    options = { :link_text => text = "Nouveau devis",
                :image_tag => image_tag("/images/add_16x16.png", :alt => text, :title => text)
              }.merge(options)
    link_to "#{options[:image_tag]} #{options[:link_text]}", new_order_commercial_step_estimate_step_quote_path(order)
  end
  
  def order_commercial_step_estimate_step_quote_link_overrided(order, quote, options = {})
    return unless Quote.can_view?(current_user)
    default_text = "Voir le devis#{" (PDF)" if options[:options] and options[:options][:format] == :pdf}"
    default_image_src = ( options[:options] and options[:options][:format] == :pdf ) ? "/images/mime_type_extensions/pdf_16x16.png" : "/images/view_16x16.png"
    
    options = { :link_text => default_text,
                :image_tag => image_tag(default_image_src, :alt => default_text, :title => default_text)
              }.merge(options)
    link_to "#{options[:image_tag]} #{options[:link_text]}", order_commercial_step_estimate_step_quote_path(order, quote, options[:options] || {})
  end
  
  def edit_order_commercial_step_estimate_step_quote_link_overrided(order, quote, options = {})
    return unless Quote.can_edit?(current_user)
    options = { :link_text => text = "Modifier le devis",
                :image_tag => image_tag("/images/edit_16x16.png", :alt => text, :title => text)
              }.merge(options)
    link_to "#{options[:image_tag]} #{options[:link_text]}", edit_order_commercial_step_estimate_step_quote_path(order, quote)
  end
  
  def delete_order_commercial_step_estimate_step_quote_link_overrided(order, quote, options = {})
    return unless Quote.can_delete?(current_user)
    options = { :link_text => text = "Supprimer le devis",
                :image_tag => image_tag("/images/delete_16x16.png", :alt => text, :title => text)
              }.merge(options)
    link_to "#{options[:image_tag]} #{options[:link_text]}", order_commercial_step_estimate_step_quote_path(order, quote), :method => :delete, :confirm => "Are you sure?"
  end
  
  def display_quote_action_buttons(order, quote)
    html = []
    html << display_quote_confirm_button(order, quote)
    html << display_quote_send_button(order, quote)
    html << display_quote_sign_button(order, quote)
    html << display_quote_order_form_button(order, quote)
    html << display_quote_cancel_button(order, quote)
    
    html << display_quote_show_pdf_button(order, quote)
    html << display_quote_show_button(order, quote)
    html << display_quote_edit_button(order, quote)
    html << display_quote_delete_button(order, quote)
    html.compact.join("&nbsp;")
  end
  
  def display_quote_show_pdf_button(order, quote)
    return unless Quote.can_view?(current_user) and !quote.uncomplete?
    order_commercial_step_estimate_step_quote_link_overrided(order, quote, :link_text => "", :options => { :format => :pdf })
  end
  
  def display_quote_show_button(order, quote)
    return unless Quote.can_view?(current_user)
    order_commercial_step_estimate_step_quote_link_overrided(order, quote, :link_text => "")
  end
  
  def display_quote_edit_button(order, quote)
    return unless Quote.can_edit?(current_user) and quote.can_be_edited?
    edit_order_commercial_step_estimate_step_quote_link_overrided(order, quote, :link_text => "")
  end
  
  def display_quote_delete_button(order, quote)
    return unless Quote.can_delete?(current_user) and quote.can_be_deleted?
    delete_order_commercial_step_estimate_step_quote_link_overrided(order, quote, :link_text => "")
  end
  
  def display_quote_confirm_button(order, quote)
    return unless Quote.can_confirm?(current_user) and quote.can_be_confirmed?
    link_to( image_tag( "/images/confirm_16x16.png",
                        :alt    => text = "Valider ce devis",
                        :title  => text ),
             order_commercial_step_estimate_step_quote_confirm_path(order, quote),
             :confirm => "Êtes-vous sûr ?\nCeci aura pour effet de générer un numéro unique pour le devis et vous ne pourrez plus le modifier." )
  end
  
  def display_quote_cancel_button(order, quote)
    return unless Quote.can_cancel?(current_user) and quote.can_be_cancelled?
    link_to( image_tag( "/images/cancel_16x16.png",
                        :alt    => text = "Annuler ce devis",
                        :title  => text ),
             order_commercial_step_estimate_step_quote_cancel_path(order, quote),
             :confirm => "Êtes-vous sûr ?" )
  end
  
  def display_quote_send_button(order, quote)
    return unless Quote.can_send_to_customer?(current_user) and quote.can_be_sended?        
    link_to( image_tag( "/images/send_to_customer_16x16.png",
                        :alt    => text = "Signaler que le devis a été envoyé au client",
                        :title  => text ),
             order_commercial_step_estimate_step_quote_send_form_path(order, quote) )
  end
  
  def display_quote_sign_button(order, quote)
    return unless Quote.can_sign?(current_user) and quote.can_be_signed?        
    link_to( image_tag( "/images/sign_16x16.png",
                        :alt    => text = "Signaler que le devis a été signé par le client",
                        :title  => text ),
             order_commercial_step_estimate_step_quote_sign_form_path(order, quote) )
  end
  
  def display_quote_order_form_button(order, quote)
    return unless Quote.can_view?(current_user) and quote.signed? and quote.order_form
    link_to( image_tag( "/images/mime_type_extensions/pdf_16x16.png",
                        :alt    => text = "Voir le #{quote.order_form_type.name}",
                        :title  => text ),
             order_commercial_step_estimate_step_quote_order_form_path(order, quote) )
  end
  
end
