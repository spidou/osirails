module ProductsCatalogHelper
  
  # This method permit to return a collection for all categories.
  def column(categories,value)
    return  categories if value == 0
    child = []
    categories.each do |category|
      child << category.child_ids if category.child_ids.size > 0
    end
    value -= 1
    column(ProductReferenceCategory.find(child),value)
  end
  
  # This method permit to know how much categories's column.
  def find_max_level
    categories = ProductReferenceCategory.find(:all)
    max_level = 0
    categories.each do |category|
      if category.ancestors.size > max_level
        max_level = category.ancestors.size
      end      
    end
    max_level
  end
  
  # This method permit to get a structure of catalog
  def show_category_column(categories,value)
    get_categories_columns = []
    collection = column(categories,value)
    get_categories_columns << "<select name='select_#{value}' id='select_#{value}' size=\"10\" multiple=\"multiple\"  class=\"select_catalog catalog_3_columns\">" +
      "<option value=\"#{-(value+1)}\" selected=\"selected\" style=\"font-weight:bold\">Il y a " + pluralize(collection.size, "categorie", "categories") + "</option>"
    
    collection.each do |category|
      get_categories_columns << "<option value=\"#{category.id}\" title=\"#{category.name}\">"+truncate("#{category.name}", 18)+" (#{category.product_references_count})</option>"
    end
    get_categories_columns << "</select>"
  end
  
  # This method permit to have a reference column
  def show_reference_column(references)
    get_reference_column = []
    get_reference_column << "<select id=\"select_reference\" size=\"10\" multiple=\"multiple\" class=\"select_catalog catalog_3_columns\" >" +
      "<option value=\"-1\" selected=\"selected\" style=\"font-weight:bold\">Il y a " + pluralize(references.size, "reference", "references") + "</option>"
    references.each do |reference|
      get_reference_column << "<option value=\"#{reference.id}\" title=\"#{reference.name}\">"+truncate("#{reference.name}", 18)+" (#{reference.products_count})</option>"
    end
    get_reference_column << "</select>"
  end
  
  # This method permit to refresh select categories column
  def refresh_select_categories(categories)
    select_update = []
    select_update << "<option value=#{categories.last} selected=selected>Il y a " + pluralize((@categories.size - 1), "categorie", "categories")+"</option>"
    categories.pop
    categories.each do |category|
      select_update << "<option value=\"#{category.id}\" title=\"#{category.name}\">" + truncate("#{category.name}", 18)+" (#{category.product_references_count})</option>"
    end
    select_update
  end
    
end