module ProductReferenceManagerHelper
  
  def display_show_link
    if params[:display] == "all"
      text = "Voir tous les produits références"#"Display actives"
      option = { :display => "active"}
    else
      text = "Voir tous les produits références annulés"#"Display all"
      option = { :display => "all"}
    end
    
    link_to( image_tag("view_16x16.png", :alt => text, :title => text) + " #{text}", product_reference_manager_path(option))
  end
  
  # This method permit to make a counter for category
  def show_counter_category(product_reference_category, show_all) 
    counter = 0
    return product_reference_category.product_references_count unless show_all

    counter += ProductReference.find_all_by_product_reference_category_id(product_reference_category.id).size
    categories_children = ProductReferenceCategory.find_all_by_product_reference_category_id(product_reference_category.id)
    categories_children.each do |category_child|
      counter += show_counter_category(category_child, show_all)
    end
    counter
  end
  
  # This method permit to have a structured page for categories
  def get_structured_categories(show_all = false)
    categories = ProductReferenceCategory.roots.actives
    list = []
    list << "<div class=\"hierarchic\"><ul class=\"parent\">"
    list = get_children(categories, list, show_all)
    list << "</ul></div>"
    list 
  end
  
  # This method permit to make a tree for categories and references
  def get_children(categories, list, show_all)
    categories.each do |category|
      if show_all or category.enabled?
        status = category.enabled? ? "category_enable" : "category_disable"
        
        list << "<li class='category #{status}'>#{category.reference} - #{category.name} (#{show_counter_category(category, show_all)}) <span class=\"action\">"
        if category.enabled?
          if category.instance_of?(ProductReferenceCategory)
            list << new_product_reference_sub_category_link_overrided(:link_text => "", :options => { :product_reference_category_id => category.id })
          elsif category.instance_of?(ProductReferenceSubCategory)
            list << new_product_reference_link_overrided(:link_text => "", :options => { :product_reference_sub_category_id => category.id })
          end
          list << send("edit_#{category.class.name.underscore}_link", category, :link_text => "")
          list << send("delete_#{category.class.name.underscore}_link_overrided", category, :link_text => "")
        end
        list << "</span></li>"
        
        references = ProductReference.find_all_by_product_reference_sub_category_id(category.id)
        
        if category.product_reference_sub_categories.any? or references.any?
          list << "<ul>"
          if category.product_reference_sub_categories.any?
            get_children(category.product_reference_sub_categories, list, show_all)
          end
          
          references.each do |reference|
            if show_all or reference.enabled?
              status = reference.enabled? ? "reference_enable" : "reference_disable"
              
              list << "<li class='reference #{status}'>#{reference.name} (#{reference.end_products_count}) <span class=\"action\">"
              if reference.enabled?
                list << product_reference_link(reference, :link_text => "")
                list << edit_product_reference_link(reference, :link_text => "")
                list << delete_product_reference_link_overrided(reference, :link_text => "")
              end
              list << "</span></li>"
            end
          end
          
          list << "</ul>"
        end
      end
    end
    list
  end
  
  # override the default method to display custom images
  def new_product_reference_category_link_overrided(options = {})
    text = "Nouvelle famille de produit référence"#"New product reference category"
    options = { :link_text => text,
                :image_tag => image_tag("category_16x16.png", :alt => text, :title => text)
              }.merge(options)
    new_product_reference_category_link(options)
  end
  
  # override the default method to display custom images
  def new_product_reference_sub_category_link_overrided(options = {})
    text = "Nouvelle sous-famille de produit référence"#"New product reference sub category"
    options = { :link_text => text,
                :image_tag => image_tag("category_16x16.png", :alt => text, :title => text)
              }.merge(options)
    new_product_reference_sub_category_link(options)
  end
  
  # override the default method to display custom images
  def new_product_reference_link_overrided(options = {})
    text = "Nouveau produit référence"#"New product reference"
    options = { :link_text => text,
                :image_tag => image_tag("reference_16x16.png", :alt => text, :title => text)
              }.merge(options)
    new_product_reference_link(options)
  end
  
  # override the default method to display a disabled button if the object is not destroyable
  def delete_product_reference_category_link_overrided(category, options = {})
    text = "Supprimer cette famille de produit référence"#"Delete this product reference category"
    options = { :link_text => text,
                :image_tag => image_tag("delete_16x16.png", :alt => text, :title => text)
              }.merge(options)
    
    if category.can_be_destroyed?
      delete_product_reference_category_link(category, options)
    else
      image_tag("delete_disable_16x16.png", :alt => text, :title => text)
    end
  end
  
  # override the default method to display a disabled button if the object is not destroyable
  def delete_product_reference_sub_category_link_overrided(category, options = {})
    text = "Supprimer cette sous-famille de produit référence"#"Delete this product reference sub category"
    options = { :link_text => text,
                :image_tag => image_tag("delete_16x16.png", :alt => text, :title => text)
              }.merge(options)
    
    if category.can_be_destroyed?
      delete_product_reference_sub_category_link(category, options)
    else
      image_tag("delete_disable_16x16.png", :alt => text, :title => text)
    end
  end
  
  # override the default method to display a disabled button if the object is not destroyable
  def delete_product_reference_link_overrided(reference, options = {})
    text = "Supprimer ce produit référence"#"Delete this product reference"
    options = { :link_text => text,
                :image_tag => image_tag("delete_16x16.png", :alt => text, :title => text)
              }.merge(options)
    
    if reference.can_be_destroyed?
      delete_product_reference_link(reference, options)
    else
      image_tag("delete_disable_16x16.png", :alt => text, :title => text)
    end
  end
  
end
