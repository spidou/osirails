module ProductReferenceManagerHelper
  
  # This method permit to have a structured page for categories
  def get_structured_category
    categories = ProductReferenceCategory.find_all_by_product_reference_category_id
    list = []
    list << "<div class='cadre'><div class='hierarchic'><ul class=\"parent\">"
    list = get_children(categories,list)
    list << "</ul></div></div>"
    list 
  end
  
  # This method permit to make a tree for categories and references
  def get_children(categories,list)
    categories.each do |category|
      delete_button = show_delete_button(category)
      list << "<li class=\"category\">#{category.name} &nbsp; (#{category.product_references_count})&nbsp; <span class=\"action\">"+
        link_to( 'Ajouter une cat&eacute;gorie' , new_product_reference_category_path(:id => category.id) )+" &brvbar; "+
        link_to( 'Ajouter une r&eacute;f&eacute;rence' , new_product_reference_path(:id => category.id) )+" &brvbar; "+
        link_to( 'Modifier', edit_product_reference_category_path(category) )+"&nbsp; #{delete_button}</span></li>"

      if category.children.size > 0 or category.product_references.size > 0
        list << "<ul>"
        if category.children.size > 0
          get_children(category.children,list)
        end
        if category.product_references.size > 0
          category.product_references.each do |reference|
            unless reference.enable == 0
            list << "<li class=\"reference\">#{reference.name} &nbsp; (#{reference.products_count})&nbsp; <span class=\"action\">"+
              link_to( 'Modifier', edit_product_reference_path(reference) )+" &brvbar; "+link_to("Supprimer", reference, { :method => :delete})+"</span></li>"
            end
          end
        end
        list << "</ul>"
      end
    end
    list
  end

  
  # This method permit to show or hide delete button
  def show_delete_button(category)
    " &brvbar; " + link_to("Supprimer", category, { :method => :delete } ) if category.can_delete? == true
  end
  
end