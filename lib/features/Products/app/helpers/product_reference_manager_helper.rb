module ProductReferenceManagerHelper
  
  # This method permit to have a structured page for categories
  def get_structured_categories
    categories = ProductReferenceCategory.find_all_by_product_reference_category_id
    list = []
    list << "<div class=\"hierarchic\"><ul class=\"parent\">"
    list = get_children(categories,list)
    list << "</ul></div>"
    list 
  end
  
  # This method permit to make a tree for categories and references
  def get_children(categories,list)
    categories.each do |category|
      list << "<li class=\"category\">#{category.name} (#{category.product_references_count}) <span class=\"action\">"
      list << show_add_button_for_product_reference_category(category)
      list << show_add_button_for_product_reference(category)
      list << show_edit_button_for_product_reference_category(category)
      list << show_delete_button_for_product_reference_category(category)
      list << "</span></li>"

      if category.children.size > 0 or category.product_references.size > 0
        list << "<ul>"
        if category.children.size > 0
          get_children(category.children,list)
        end
        if category.product_references.size > 0
          category.product_references.each do |reference|
            unless reference.enable == 0
              list << "<li class=\"reference\">#{reference.name} (#{reference.products_count}) <span class=\"action\">"
              list << show_edit_button_for_product_reference(reference)
              list << show_delete_button_for_product_reference(reference)
              list << "</span></li>"
            end
          end
        end
        list << "</ul>"
      end
    end
    list
  end
  
  # display (or not) the add button for product reference
  def show_add_button_for_product_reference(category)
    link_to(image_tag("/images/reference16x16.png", :alt => 'Ajouter une r&eacute;f&eacute;rence', :title => 'Ajouter une r&eacute;f&eacute;rence') , new_product_reference_path(:id => category.id) ) if ProductReference.can_add?(current_user)  
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
      link_to(image_tag("/images/category16x16.png", :alt => 'Ajouter une cat&eacute;gorie', :title => 'Ajouter une cat&eacute;gorie') , new_product_reference_category_path(:id => category.id) )
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