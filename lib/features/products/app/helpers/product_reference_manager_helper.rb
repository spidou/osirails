module ProductReferenceManagerHelper
  
  # This method permit to show or hide action menu
  def show_action_menu(type)
    actions = []
    actions << "<h1><span class='gray_color'>Action</span></h1>"
    actions << "<ul>"
    actions << "<li>#{show_add_link_for_product_reference_category}</li>"
    actions << "<li>#{type != "show_all" ? link_to("Tout affich&eacute;", :action => "index", :type => "show_all") : link_to("Affich&eacute; Actifs", :action => "index")}</li>"
    actions << "</ul>"
  end
  
  # This method permit to make a counter for category
  def show_counter_category(product_reference_category, show_all) 
    counter = 0
    return product_reference_category.product_references_count if show_all == false

    counter += ProductReference.find_all_by_product_reference_category_id(product_reference_category.id).size
    categories_children = ProductReferenceCategory.find_all_by_product_reference_category_id(product_reference_category.id)
    categories_children.each do |category_child|
      counter += show_counter_category(category_child, show_all)
    end
    counter
  end
  
  # This method permit to have a structured page for categories
  def get_structured_categories(show_all = false)
    categories = ProductReferenceCategory.find_all_by_product_reference_category_id(nil)
    list = []
    list << "<div class=\"hierarchic\"><ul class=\"parent\">"
    list = get_children(categories,list,show_all)
    list << "</ul></div>"
    list 
  end
  
  # This method permit to make a tree for categories and references
  def get_children(categories,list,show_all)
    categories.each do |category|
      unless category.enable == show_all
        status = category.enable ? "category_enable" : "category_disable"
        
        list << "<li class='category #{status}'>#{category.name} (#{show_counter_category(category, show_all)}) <span class=\"action\">"
        if category.enable == true
          list << show_add_button_for_product_reference_category(category) 
          list << show_add_button_for_product_reference(category)
          list << show_edit_button_for_product_reference_category(category)
          list << show_delete_button_for_product_reference_category(category)
        end
        list << "</span></li>"
        
        references = ProductReference.find_all_by_product_reference_category_id(category.id)
        
        if category.children.size > 0 or references.size > 0
          list << "<ul>"
          if category.children.size > 0
            get_children(category.children,list,show_all)
          end
          
          unless references.size == 0
            references.each do |reference|
              unless reference.enable == show_all
                status = reference.enable ? "reference_enable" : "reference_disable"
                
                list << "<li class='reference #{status}'>#{reference.name} (#{reference.products_count}) <span class=\"action\">"
                if reference.enable == true
                  list << show_edit_button_for_product_reference(reference)
                  list << show_delete_button_for_product_reference(reference)
                end
                list << "</span></li>"
              end
            end
          end
          list << "</ul>"
        end
      end
    end
    list
  end
  
  # display (or not) the add button for product reference
  def show_add_button_for_product_reference(category)
    link_to(image_tag("/images/reference_16x16.png", :alt => 'Ajouter une r&eacute;f&eacute;rence', :title => 'Ajouter une r&eacute;f&eacute;rence') , new_product_reference_path(:id => category.id) ) if ProductReference.can_add?(current_user)  
  end
  
  # display (or not) the edit button for product reference
  def show_edit_button_for_product_reference(reference)
    if controller.can_edit?(current_user) and ProductReference.can_edit?(current_user)
      link_to(image_tag("/images/edit_16x16.png", :alt =>"Modifier", :title =>"Modifier"), edit_product_reference_path(reference))
    end
  end
  
  # display (or not) the delete button for product reference
  def show_delete_button_for_product_reference(reference)
    if controller.can_delete?(current_user) and ProductReference.can_delete?(current_user)
      link_to(image_tag("/images/delete_16x16.png", :alt =>"Supprimer", :title =>"Supprimer"), reference, { :method => :delete, :confirm => 'Etes vous sûr  ?'})
    end
  end
  
  # display (or not) the add link for product reference
  def show_add_link_for_product_reference_category
    link_to('Ajouter une cat&eacute;gorie', new_product_reference_category_path ) if ProductReferenceCategory.can_add?(current_user)
  end
  
  # display (or not) the add button for product reference category
  def show_add_button_for_product_reference_category(category)
    if controller.can_add?(current_user) and ProductReferenceCategory.can_add?(current_user)
      link_to(image_tag("/images/category_16x16.png", :alt => 'Ajouter une cat&eacute;gorie', :title => 'Ajouter une cat&eacute;gorie') , new_product_reference_category_path(:id => category.id) )
    end
  end
  
  # display (or not) the edit button for product reference category
  def show_edit_button_for_product_reference_category(category)
    if controller.can_edit?(current_user) and ProductReferenceCategory.can_delete?(current_user)
      link_to(image_tag("/images/edit_16x16.png", :alt =>"Modifier", :title =>"Modifier"), edit_product_reference_category_path(category))
    end
  end
  
  # display (or not) the delete button for product reference category
  def show_delete_button_for_product_reference_category(category)
    if controller.can_delete?(current_user) and ProductReferenceCategory.can_delete?(current_user)
      if category.can_destroy?
        link_to(image_tag("/images/delete_16x16.png", :alt =>"Supprimer", :title =>"Supprimer"), category, { :method => :delete, :confirm => 'Etes vous sûr  ?' } )
      else
        image_tag("/images/delete_disable_16x16.png", :alt =>"Supprimer", :title =>"Supprimer")
      end
    end
  end
  
end
