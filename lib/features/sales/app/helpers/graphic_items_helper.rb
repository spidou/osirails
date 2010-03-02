module GraphicItemsHelper
  def graphic_items_link(object_class)
    if object_class.name == "Mockup"
      text = "Voir les maquettes du dossier"
      link_to(image_tag("view_16x16.png", :alt => text, :title => text) + " " + text, order_mockups_path)
    elsif object_class.name == "GraphicDocument"
      text = "Voir les documents graphiques du dossier"
      link_to(image_tag("view_16x16.png", :alt => text, :title => text) + " " + text, order_graphic_documents_path)
    end
  end
  
  def new_graphic_item_link(object_class)
    if object_class.name == "Mockup"
      text = "Nouvelle maquette"
      link_to(image_tag("add_16x16.png", :alt => text, :title => text) + " " + text, new_order_mockup_path)
    elsif object_class.name == "GraphicDocument"
      text = "Nouveau document graphique"
      link_to(image_tag("add_16x16.png", :alt => text, :title => text) + " " + text, new_order_graphic_document_path)
    end
  end
  
  def edit_graphic_item_link(object)
    if object.class.name == "Mockup"
      text = "Modifier la maquette"
      link_to(image_tag("edit_16x16.png", :alt => text, :title => text) + " " + text, edit_order_mockup_path(object.order,object))
    elsif object.class.name == "GraphicDocument"
      text = "Modifier le document graphique"
      link_to(image_tag("edit_16x16.png", :alt => text, :title => text) + " " + text, edit_order_graphic_document_path(object.order,object))
    end
  end
  
  def delete_graphic_item_link(object)
    if object.class.name == "Mockup"
      text = "Supprimer la maquette"
      link_to(image_tag("delete_16x16.png", :alt => text, :title => text) + " " + text, order_mockup_path(object.order,object), :method => :delete, :confirm => "Êtes-vous sûr ?")
    elsif object.class.name == "GraphicDocument"
      text = "Supprimer le document graphique"
      link_to(image_tag("delete_16x16.png", :alt => text, :title => text) + " " + text, order_graphic_document_path(object.order,object), :method => :delete, :confirm => "Êtes-vous sûr ?")
    end
  end
  
  def cancel_graphic_item_link(object)
    if object.class.name == "Mockup"
      text = "Désactiver la maquette"
      link_to(image_tag("cancel_16x16.png", :alt => text, :title => text) + " " + text, order_mockup_cancel_path(object.order,object), :confirm => "Êtes-vous sûr ?")
    elsif object.class.name == "GraphicDocument"
      text = "Désactiver le document graphique"
      link_to(image_tag("cancel_16x16.png", :alt => text, :title => text) + " " + text, order_graphic_document_cancel_path(object.order,object), :confirm => "Êtes-vous sûr ?")
    end
  end
  
  def display_graphic_item_summary_view_button(object)
    if object.class.name == "Mockup" 
      text = "Voir cette maquette"
      link_to(image_tag("view_16x16.png", :alt => text, :title => text), order_mockup_path(object.order,object))
    elsif object.class.name == "GraphicDocument"
      text = "Voir ce document graphique"
      link_to(image_tag("view_16x16.png", :alt => text, :title => text), order_graphic_document_path(object.order,object))
    end
  end
  
  def display_graphic_item_summary_edit_button(object)
    if object.class.name == "Mockup" 
      text = "Modifier cette maquette"
      link_to(image_tag("edit_16x16.png", :alt => text, :title => text), edit_order_mockup_path(object.order,object))
    elsif object.class.name == "GraphicDocument"
      text = "Modifier ce document graphique"
      link_to(image_tag("edit_16x16.png", :alt => text, :title => text), edit_order_graphic_document_path(object.order,object))
    end
  end
  
  def display_graphic_item_summary_delete_button(object)
    if object.class.name == "Mockup" 
      text = "Supprimer cette maquette"
      link_to(image_tag("delete_16x16.png", :alt => text, :title => text), order_mockup_path(object.order,object), :method => :delete, :confirm => "Êtes-vous sûr ?")
    elsif object.class.name == "GraphicDocument"
      text = "Supprimer ce document graphique"
      link_to(image_tag("delete_16x16.png", :alt => text, :title => text), order_graphic_document_path(object.order,object), :method => :delete, :confirm => "Êtes-vous sûr ?")
    end
  end
  
  def display_graphic_item_summary_cancel_button(object)
    if object.class.name == "Mockup" 
      text = "Désactiver cette maquette"
      link_to(image_tag("cancel_16x16.png", :alt => text, :title => text), order_mockup_cancel_path(object.order,object), :confirm => "Êtes-vous sûr ?")
    elsif object.class.name == "GraphicDocument"
      text = "Désactiver ce document graphique"
      link_to(image_tag("cancel_16x16.png", :alt => text, :title => text), order_graphic_document_cancel_path(object.order,object), :confirm => "Êtes-vous sûr ?")
    end
  end
  
  def display_graphic_item_summary_image_download_link(object)
    link_to("", object.current_image.url)
  end
  
  def display_graphic_item_summary_source_download_link(object)
    link_to(image_tag("picture_source_16x16.png", :alt => text, :title => text), object.current_source.url)
  end
  
  def display_graphic_item_summary_image_spool_actions(object)
    if object.class.name == "Mockup" 
      remove_path = order_mockup_remove_from_spool_path({:mockup_id => object.id, :file_type => "image", :item_id => object.spool_item_id("image",current_user)})
      add_path = order_mockup_add_to_spool_path({:mockup_id => object.id, :file_type => "image"})
    elsif object.class.name == "GraphicDocument"
      remove_path = order_graphic_document_remove_from_spool_path({:graphic_document_id => object.id, :file_type => "image", :item_id => object.spool_item_id("image",current_user)})
      add_path = order_graphic_document_add_to_spool_path({:graphic_document_id => object.id, :file_type => "image"})
    end 
  
    if object.is_in_user_spool("image",current_user)
      link_to_remote(strong("Retirer de la file d'attente"), :url => remove_path, :html => {:id => "spool_action_for_#{object.id}_image"})
    else      
      link_to_remote(strong("Ajouter à la file d'attente"), :url => add_path, :html => {:id => "spool_action_for_#{object.id}_image"})
    end
  end
  
  def display_graphic_item_summary_source_spool_actions(object)   
    if object.class.name == "Mockup" 
      remove_path = order_mockup_remove_from_spool_path({:mockup_id => object.id, :file_type => "source", :item_id => object.spool_item_id("source",current_user)})
      add_path = order_mockup_add_to_spool_path({:mockup_id => object.id, :file_type => "source"})
    elsif object.class.name == "GraphicDocument"
      remove_path = order_graphic_document_remove_from_spool_path({:graphic_document_id => object.id, :file_type => "source", :item_id => object.spool_item_id("source",current_user)})
      add_path = order_graphic_document_add_to_spool_path({:graphic_document_id => object.id, :file_type => "source"})
    end 
    
    if object.is_in_user_spool("source",current_user)
      link_to_remote(strong("Retirer de la file d'attente"), :url => remove_path, :html => {:id => "spool_action_for_#{object.id}_source"})
    else        
      link_to_remote(strong("Ajouter à la file d'attente"), :url => add_path, :html => {:id => "spool_action_for_#{object.id}_source"})
    end 
  end
  
  def display_user_spool
    html = '<p id="spool">'
    html << render(:partial => 'graphic_item_spool_items/spool')
    html << '</p>'
    html << '<ul>'
    html << ' <li>'
    html <<     link_to( image_tag("view_16x16.png") + " Voir la file d'attente (<span id='spool_size'>#{@spool.size}</span>)", order_graphic_item_spool_items_path)
    html << ' </li>'
    html << '</ul>'
  end
  
  def display_empty_spool_link
    content_tag(:p,link_to_remote(strong("VIDER LA LISTE D'ATTENTE"), :url => order_empty_graphic_item_spool_items_path, :confirm => "Êtes-vous sûr ?"))
  end
end
