module GraphicItemsHelper
  def graphic_items_link(object_class)
    if object_class.name == "Mockup"
      text = "Voir toutes les maquettes du dossier"
      link_to(image_tag("view_16x16.png", :alt => text, :title => text) + " " + text, order_mockups_path)
    elsif object_class.name == "GraphicDocument"
      text = "Voir tous les documents graphiques du dossier"
      link_to(image_tag("view_16x16.png", :alt => text, :title => text) + " " + text, order_graphic_documents_path)
    end
  end
  
  def new_graphic_item_link(object_class)
    if object_class.name == "Mockup"
      text = "Ajouter une nouvelle maquette au dossier"
      link_to(image_tag("add_16x16.png", :alt => text, :title => text) + " " + text, new_order_mockup_path)
    elsif object_class.name == "GraphicDocument"
      text = "Ajouter un nouveau document graphique au dossier"
      link_to(image_tag("add_16x16.png", :alt => text, :title => text) + " " + text, new_order_graphic_document_path)
    end
  end
  
  def edit_graphic_item_link(object)
    if object.class.name == "Mockup"
      text = "Éditer la maquette"
      link_to(image_tag("edit_16x16.png", :alt => text, :title => text) + " " + text, edit_order_mockup_path(object.order,object))
    elsif object.class.name == "GraphicDocument"
      text = "Éditer le document graphique"
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
      text = "voir cette maquette"
      link_to(image_tag("view_16x16.png", :alt => text, :title => text), order_mockup_path(object.order,object))
    elsif object.class.name == "GraphicDocument"
      text = "voir ce document graphique"
      link_to(image_tag("view_16x16.png", :alt => text, :title => text), order_graphic_document_path(object.order,object))
    end
  end
  
  def display_graphic_item_summary_edit_button(object)
    if object.class.name == "Mockup" 
      text = "éditer cette maquette"
      link_to(image_tag("edit_16x16.png", :alt => text, :title => text), edit_order_mockup_path(object.order,object))
    elsif object.class.name == "GraphicDocument"
      text = "éditer ce document graphique"
      link_to(image_tag("edit_16x16.png", :alt => text, :title => text), edit_order_graphic_document_path(object.order,object))
    end
  end
  
  def display_graphic_item_summary_delete_button(object)
    if object.class.name == "Mockup" 
      text = "supprimer cette maquette"
      link_to(image_tag("delete_16x16.png", :alt => text, :title => text), order_mockup_path(object.order,object), :method => :delete, :confirm => "Êtes-vous sûr ?")
    elsif object.class.name == "GraphicDocument"
      text = "supprimer ce document graphique"
      link_to(image_tag("delete_16x16.png", :alt => text, :title => text), order_graphic_document_path(object.order,object), :method => :delete, :confirm => "Êtes-vous sûr ?")
    end
  end
  
  def display_graphic_item_summary_cancel_button(object)
    if object.class.name == "Mockup" 
      text = "désactiver cette maquette"
      link_to(image_tag("cancel_16x16.png", :alt => text, :title => text), order_mockup_cancel_path(object.order,object), :confirm => "Êtes-vous sûr ?")
    elsif object.class.name == "GraphicDocument"
      text = "désactiver ce document graphique"
      link_to(image_tag("cancel_16x16.png", :alt => text, :title => text), order_graphic_document_cancel_path(object.order,object), :confirm => "Êtes-vous sûr ?")
    end
  end
  
  def display_graphic_item_summary_image_download_button(object)
    if object.class.name == "Mockup" 
      text = "télécharger le fichier image de cette maquette"
    else
      test = "télécharger le fichier image de ce document graphique"
    end
    link_to(image_tag("picture_file_16x16.png", :alt => text, :title => text), object.current_image.url)
  end
  
  def display_graphic_item_summary_source_download_button(object)
    if object.current_version.source_file_name
      if object.class.name == "Mockup" 
      text = "télécharger le fichier source de cette maquette"
    else
      test = "télécharger le fichier source de ce document graphique"
    end
      link_to(image_tag("picture_source_16x16.png", :alt => text, :title => text), object.current_source.url)
    end
  end
end
