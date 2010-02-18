module DeliveryInterventionsHelper
  
  def display_delivery_interventions_for(delivery_note)
    return unless DeliveryIntervention.can_list?(current_user)
    delivery_interventions = delivery_note.delivery_interventions
    
    if delivery_interventions and !delivery_interventions.empty?
      render :partial => 'delivery_interventions/delivery_interventions', :object => delivery_interventions
    else
      content_tag(:p, "Aucune intervention n'a été planifié pour ce bon de livraison")
    end
  end
  
  def display_actions_for_delivery_intervention(delivery_intervention)
    html = []
    html << display_delivery_intervention_download_report_button(delivery_intervention, :link_text => '')
    html << display_delivery_intervention_show_button(delivery_intervention, :link_text => '')
    html.compact.join("&nbsp;")
  end
  
  def display_delivery_intervention_show_button(delivery_intervention, options = {})
    return unless DeliveryIntervention.can_view?(current_user)
    delivery_note = delivery_intervention.delivery_note
    order = delivery_note.order
    
    default_text = "Voir la fiche complète de l'intervention"
    
    options = { :link_text => default_text,
                :image_tag => image_tag("view_16x16.png", :alt => default_text, :title => default_text)
              }.merge(options)
    link_to options[:image_tag] + options[:link_text], order_pre_invoicing_step_delivery_step_delivery_note_delivery_intervention_path(order, delivery_note, delivery_intervention, options[:options] || {})
  end
  
  def display_delivery_intervention_download_report_button(delivery_intervention, options = {})
    return unless DeliveryIntervention.can_view?(current_user) and delivery_intervention.report_file_name
    delivery_note = delivery_intervention.delivery_note
    order = delivery_note.order
    
    default_text = "Télécharger la fiche d'intervention (PDF)"
    
    options = { :link_text => default_text,
                :image_tag => image_tag("mime_type_extensions/pdf_16x16.png", :alt => default_text, :title => default_text)
              }.merge(options)
    link_to options[:image_tag] + options[:link_text], order_pre_invoicing_step_delivery_step_delivery_note_delivery_intervention_report_path(order, delivery_note, delivery_intervention, options[:options] || {})
  end
  
end
