module GraphicItemsHelper
  
  def graphic_items_link(object_class)
    if object_class.name == "Mockup"
      text = "Voir les maquettes du dossier"
      path = order_mockups_path
    elsif object_class.name == "GraphicDocument"
      text = "Voir les documents graphiques du dossier"
      path = order_graphic_documents_path
    end
    link_to(text, path, 'data-icon' => :index)
  end
  
  def graphic_item_link(object)
    if object.class.name == "Mockup"
      text = "Voir la maquette"
      path = order_mockup_path(object.order, object)
    elsif object.class.name == "GraphicDocument"
      text = "Voir le document graphique"
      path = order_graphic_document_path(object.order, object)
    end
    link_to(text, path, 'data-icon' => :show)
  end
  
  def new_graphic_item_link(object_class)
    if object_class.name == "Mockup"
      text = "Nouvelle maquette"
      path = new_order_mockup_path
    elsif object_class.name == "GraphicDocument"
      text = "Nouveau document graphique"
      path = new_order_graphic_document_path
    end
    link_to(text, path, 'data-icon' => :new)
  end
  
  def edit_graphic_item_link(object)
    if object.class.name == "Mockup"
      text = "Modifier la maquette"
      path = edit_order_mockup_path(object.order,object)
    elsif object.class.name == "GraphicDocument"
      text = "Modifier le document graphique"
      path = edit_order_graphic_document_path(object.order,object)
    end
    link_to(text, path, 'data-icon' => :edit)
  end
  
  def delete_graphic_item_link(object)
    if object.class.name == "Mockup"
      text = "Supprimer la maquette"
      path = order_mockup_path(object.order,object)
    elsif object.class.name == "GraphicDocument"
      text = "Supprimer le document graphique"
      path = order_graphic_document_path(object.order,object)
    end
    link_to(text, path, :method => :delete, :confirm => "Êtes-vous sûr ?", 'data-icon' => :delete)
  end
  
  def cancel_graphic_item_link(object)
    if object.class.name == "Mockup"
      text = "Désactiver la maquette"
      path = order_mockup_cancel_path(object.order,object)
    elsif object.class.name == "GraphicDocument"
      text = "Désactiver le document graphique"
      path = order_graphic_document_cancel_path(object.order,object)
    end
    link_to(text, path, :confirm => "Êtes-vous sûr ?", 'data-icon' => :cancel)
  end
  
  def display_graphic_item_summary_preview_button(object, press_proof = nil)
    parent = press_proof || object.end_product
    image = image_tag("preview_16x16.gif", :alt => text = "Aperçu", :title => text)
    link_to(image, object.current_image.url(:medium),
            :rel => "lightbox[#{parent.class.name.underscore}_#{parent.id}]",
            :title => "#{object.name} : #{object.short_description}")
  end
  
  def display_graphic_item_summary_download_button(object)
    image = image_tag("download_16x16.png", :alt => text = "Télécharger", :title => text)
    link_to(image, object.current_image.url(:medium))
  end
  
  def display_graphic_item_summary_view_button(object)
    if object.class.name == "Mockup" 
      text = "Voir cette maquette"
      path = order_mockup_path(object.order,object)
    elsif object.class.name == "GraphicDocument"
      text = "Voir ce document graphique"
      path = order_graphic_document_path(object.order,object)
    end
    link_to(image_tag("view_16x16.png", :alt => text, :title => text), path)
  end
  
  def display_graphic_item_summary_edit_button(object)
    if object.class.name == "Mockup" 
      text = "Modifier cette maquette"
      path = edit_order_mockup_path(object.order,object)
    elsif object.class.name == "GraphicDocument"
      text = "Modifier ce document graphique"
      path = edit_order_graphic_document_path(object.order,object)
    end
    link_to(image_tag("edit_16x16.png", :alt => text, :title => text), path)
  end
  
  def display_graphic_item_summary_delete_button(object)
    if object.class.name == "Mockup" 
      text = "Supprimer cette maquette"
      path = order_mockup_path(object.order,object)
    elsif object.class.name == "GraphicDocument"
      text = "Supprimer ce document graphique"
      path = order_graphic_document_path(object.order,object)
    end
    link_to(image_tag("delete_16x16.png", :alt => text, :title => text), path, :method => :delete, :confirm => "Êtes-vous sûr ?")
  end
  
  def display_graphic_item_summary_cancel_button(object)
    if object.class.name == "Mockup" 
      text = "Désactiver cette maquette"
      path = order_mockup_cancel_path(object.order,object)
    elsif object.class.name == "GraphicDocument"
      text = "Désactiver ce document graphique"
      path = order_graphic_document_cancel_path(object.order,object)
    end
    link_to(image_tag("cancel_16x16.png", :alt => text, :title => text), path, :confirm => "Êtes-vous sûr ?")
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
      link_to_remote("Retirer de la file d'attente", :url => remove_path, :html => {:id => "spool_action_for_#{object.id}_image"})
    else      
      link_to_remote("Ajouter à la file d'attente", :url => add_path, :html => {:id => "spool_action_for_#{object.id}_image"})
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
      link_to_remote("Retirer de la file d'attente", :url => remove_path, :html => {:id => "spool_action_for_#{object.id}_source"})
    else        
      link_to_remote("Ajouter à la file d'attente", :url => add_path, :html => {:id => "spool_action_for_#{object.id}_source"})
    end 
  end
  
  def display_user_spool(user = current_user)
    spool_items = GraphicItemSpoolItem.spool_items_by_user(user)
    html = '<p id="spool">'
    html << render(:partial => 'graphic_item_spool_items/spool', :object => spool_items)
    html << '</p>'
    html << '<ul>'
    html << ' <li>'
    html <<     link_to("Voir la file d'attente (<span id='spool_size'>#{spool_items.size}</span>)", order_graphic_item_spool_items_path, 'data-icon' => :show)
    html << ' </li>'
    html << '</ul>'
  end
  
  def display_user_spool_in_contextual_menu
    add_contextual_menu_item(:spool_items, :force_not_list => true) { display_user_spool }
  end
  
  def display_empty_spool_link
    content_tag(:p,link_to_remote("VIDER LA LISTE D'ATTENTE", :url => order_empty_graphic_item_spool_items_path, :confirm => "Êtes-vous sûr ?"))
  end
end
