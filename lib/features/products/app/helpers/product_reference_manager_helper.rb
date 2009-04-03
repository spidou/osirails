module ProductReferenceManagerHelper
  
  # This method permit to show or hide action menu
  def show_action_menu(type)
    if (controller.can_add?(current_user) and (ProductReferenceCategory.can_add?(current_user) or ProductReference.can_add?(current_user))) or controller.can_view?(current_user)
      actions = []
      actions << "<h1><span class='gray_color'>Action</span> <span class='blue_color'>possible</span></h1>"
      actions << "<ul>"
      if controller.can_add?(current_user) and ProductReferenceCategory.can_add?(current_user)
        actions << "<li>#{new_product_reference_category_link}</li>"
      end
      
      if controller.can_add?(current_user) and ProductReference.can_add?(current_user)
        actions << "<li>"+link_to("<img src='/images/reference_16x16.png' alt='Ajouter une r&eacute;f&eacute;rence' title='Ajouter une r&eacute;f&eacute;rence' /> Ajouter une r&eacute;f&eacute;rence", new_product_reference_path )+"</li>"
      end
      
      if controller.can_view?(current_user) # and (ProductReferenceCategory.find(:all).size == ProductReferenceCategory.find_all_by_enable(true).size)
        if (ProductReference.find(:all).size != ProductReference.find_all_by_enable(true).size) or (ProductReferenceCategory.find(:all).size == ProductReferenceCategory.find_all_by_enable(true).size)
          actions << "<li>#{type != "show_all" ? link_to("<img alt='Tout afficher' title='Tout afficher' src='/images/view_16x16.png' /> Tout afficher", :action => "index", :type => "show_all") : link_to("<img alt='Afficher actifs' title='Afficher actifs' src='/images/view_16x16.png' /> Afficher actifs", :action => "index")}</li>"
        end
      end
      actions << "</ul>"
    end
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
          list << new_product_reference_category_link(category,"") 
          list << new_product_reference_link(category)
          list << edit_product_reference_category_link(category, :link_text =>"")
          list << delete_product_reference_category_link(category)
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
<<<<<<< HEAD:lib/features/products/app/helpers/product_reference_manager_helper.rb
                  list << edit_product_reference_link(reference)
                  list << delete_product_reference_link(reference)
=======
                  list << edit_product_reference_link(reference,:link_text =>"")
                  list << delete_product_reference_link(reference,:link_text =>"")
>>>>>>> Implementation and modification of the method to generate dynamic helpers to display links:lib/features/products/app/helpers/product_reference_manager_helper.rb
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
  def new_product_reference_link(category)
    link_to(image_tag("/images/reference_16x16.png", :alt => 'Ajouter une r&eacute;f&eacute;rence', :title => 'Ajouter une r&eacute;f&eacute;rence') , new_product_reference_path(:id => category.id) ) if ProductReference.can_add?(current_user)  
  end
  
<<<<<<< HEAD:lib/features/products/app/helpers/product_reference_manager_helper.rb
  # display (or not) the edit button for product reference
  def edit_product_reference_link(reference)
    if controller.can_edit?(current_user) and ProductReference.can_edit?(current_user)
      link_to(image_tag("/images/edit_16x16.png", :alt =>"Modifier", :title =>"Modifier"), edit_product_reference_path(reference))
    end
  end
  
  # display (or not) the delete button for product reference
  def delete_product_reference_link(reference)
    if controller.can_delete?(current_user) and ProductReference.can_delete?(current_user)
      link_to(image_tag("/images/delete_16x16.png", :alt =>"Supprimer", :title =>"Supprimer"), reference, { :method => :delete, :confirm => 'Etes vous sûr  ?'})
    end
  end
  
=======
>>>>>>> Implementation and modification of the method to generate dynamic helpers to display links:lib/features/products/app/helpers/product_reference_manager_helper.rb
  
  # display (or not) the add button for product reference category
  def new_product_reference_category_link(category=nil, txt="Ajouter une cat&eacute;gorie")
    category.nil? ?  path_method =  new_product_reference_category_path : path_method = new_product_reference_category_path(:id => category.id)
    if controller.can_add?(current_user) and ProductReferenceCategory.can_add?(current_user)
      link_to(image_tag("/images/category_16x16.png", :alt => 'Ajouter une cat&eacute;gorie', :title => 'Ajouter une cat&eacute;gorie')+" #{txt}" ,  path_method )
<<<<<<< HEAD:lib/features/products/app/helpers/product_reference_manager_helper.rb
    end
  end
  
  # display (or not) the edit button for product reference category
  def edit_product_reference_category_link(category)
    if controller.can_edit?(current_user) and ProductReferenceCategory.can_delete?(current_user)
      link_to(image_tag("/images/edit_16x16.png", :alt =>"Modifier", :title =>"Modifier"), edit_product_reference_category_path(category))
=======
>>>>>>> Implementation and modification of the method to generate dynamic helpers to display links:lib/features/products/app/helpers/product_reference_manager_helper.rb
    end
  end

  
  # display (or not) the delete button for product reference category
  def delete_product_reference_category_link(category)
    if controller.can_delete?(current_user) and ProductReferenceCategory.can_delete?(current_user)
      if category.can_be_destroyed?
        link_to(image_tag("/images/delete_16x16.png", :alt =>"Supprimer", :title =>"Supprimer"), category, { :method => :delete, :confirm => 'Etes vous sûr  ?' } )
      else
        image_tag("/images/delete_disable_16x16.png", :alt =>"Supprimer", :title =>"Supprimer")
      end
    end
  end
  
end
