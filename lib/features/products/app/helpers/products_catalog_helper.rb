module ProductsCatalogHelper

  MAX_LEVEL_CONS = 1 #FIXME This constant will be configurable by administrateur
  
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
    if max_level > MAX_LEVEL_CONS
      return MAX_LEVEL_CONS
    end
    max_level
  end
  
  # This method permit to get a structure of catalog
  def show_category_column(categories,value)
    get_categories_columns = []
    collection = column(categories,value)
    first_select = (value == 0 ? "" : "sous-")

    get_categories_columns << "<select id='select_#{value}' size=\"10\" multiple=\"multiple\"  class=\"select_catalog catalog_3_columns\" onclick=\"refreshCategories(this, '#{find_max_level}', 0)\">"
    get_categories_columns << "<option style=\"font-weight:bold\" selected=\"selected\" value=\"0\">Il y a " + pluralize(collection.size, "#{first_select}famille", "#{first_select}familles") + "</option>"
    
    collection.each do |category|
      get_categories_columns << "<option value=\"#{category.id}\" title=\"#{category.name}\">"+truncate("#{category.name}", 18)+" (#{category.product_references_count})</option>"
    end
    get_categories_columns << "</select>"
  end
  
  # This method permit to have a reference column
  def show_reference_column(references)
    get_reference_column = []
    get_reference_column << "<select id=\"select_reference\" size=\"10\" multiple=\"multiple\" class=\"select_catalog catalog_3_columns\" onclick=\"refreshReferenceInformation(this)\" >" +
      "<option style=\"font-weight:bold\" selected=\"selected\" value=\"0\" >Il y a " + pluralize(references.size, "reference", "references") + "</option>"
    references.each do |reference|
      get_reference_column << "<option value=\"#{reference.id}\" title=\"#{reference.name}\">"+truncate("#{reference.name}", 18)+" (#{reference.products_count})</option>"
    end
    get_reference_column << "</select>"
  end

  # This method permit to show products array
  def show_products(products)
    products_array = []

    products.each do |product|
      reference = ProductReference.find(product.product_reference_id)
      category = ProductReferenceCategory.find(reference.product_reference_category_id)

      products_array << "<tr id=\"product_#{product.id}\" title=\"Cliquer pour afficher les d&eacute;tails du produit\" onclick=\"refreshProduct(this)\">"
      products_array << "<td>#{product.name}</td>"
      products_array << "<td>"+category.name+"</td>"
      products_array << "<td>"+reference.name+"</td>"
      products_array << "<td></td>"
      products_array << "<td></td>"
      products_array << "</tr>"
    end
    products_array
  end
    
end