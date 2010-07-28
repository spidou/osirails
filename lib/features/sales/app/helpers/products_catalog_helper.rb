module ProductsCatalogHelper

#  MAX_LEVEL_CONS = 1 #FIXME This constant should be configurable via the user interface
  
 # # This method permit to return a collection for all categories.
 # def column(categories,value)
 #   return categories if value == 0
 #   child = []
 #   categories.each do |category|
 #     child << category.child_ids if category.child_ids.size > 0
 #   end
 #   value -= 1
 #   column(ProductReferenceCategory.find(child),value)
 # end
  
#  # This method permit to know how much categories's column.
#  def find_max_level
#    categories = ProductReferenceCategory.find(:all)
#    max_level = 0
#    categories.each do |category|
#      if category.ancestors.size > max_level
#        max_level = category.ancestors.size
#      end      
#    end
#    if max_level > MAX_LEVEL_CONS
#      return MAX_LEVEL_CONS
#    end
#    max_level
#  end
  
#  # This method permit to get a structure of catalog
#  def show_category_column(categories,value)
#    get_categories_columns = []
#    collection = column(categories,value)
#    first_select = (value == 0 ? "" : "sous-")
#
#    get_categories_columns << "<select id='select_#{value}' size=\"10\" multiple=\"multiple\"  class=\"select_catalog catalog_3_columns\" onclick=\"refreshCategories(this, 1, 0)\">"
#    get_categories_columns << "<option style=\"font-weight:bold\" selected=\"selected\" value=\"0\">Il y a " + pluralize(collection.size, "#{first_select}famille", "#{first_select}familles") + "</option>"
#    
#    collection.each do |category|
#      get_categories_columns << "<option value=\"#{category.id}\" title=\"#{category.name}\">#{category.name} (#{category.product_references_count})</option>"
#    end
#    get_categories_columns << "</select>"
#  end
  
 # # This method permit to have a reference column
 # def show_reference_column(references)
 #   get_reference_column = []
 #   get_reference_column << "<select id=\"select_reference\" size=\"10\" multiple=\"multiple\" class=\"select_catalog catalog_3_columns\" onclick=\"refreshReferenceInformation(this)\" >" +
 #     "<option style=\"font-weight:bold\" selected=\"selected\" value=\"0\" >Il y a " + pluralize(references.size, "reference", "references") + "</option>"
 #   references.each do |reference|
 #     get_reference_column << "<option value=\"#{reference.id}\" title=\"#{reference.name}\">#{reference.name} (#{reference.end_products_count})</option>"
 #   end
 #   get_reference_column << "</select>"
 # end
  
  def select_for_product_reference_categories(categories)
    html = ""
    html << "<select id=\"select_product_reference_categories\" size=\"10\" multiple=\"multiple\" class=\"select_catalog catalog_3_columns\" onchange=\"update_product_reference_sub_categories(this)\">"
    html << options_for_product_reference_categories(categories)
    html << "</select>"
  end
  
  def options_for_product_reference_categories(categories)
    html = ""
    html << "<option style=\"font-weight:bold\" selected=\"selected\" value=\"0\">Il y a #{pluralize(categories.size, "famille", "familles")}</option>"
    html << categories.map{ |category| "<option value=\"#{category.id}\" title=\"Cette famille contient #{pluralize(category.product_references_count, "produit référence", "produits référence")}\">#{category.reference} - #{category.name} (#{category.product_references_count})</option>" }.to_s
  end
  
  def select_for_product_reference_sub_categories(categories)
    html = ""
    html << "<select id=\"select_product_reference_sub_categories\" size=\"10\" multiple=\"multiple\" class=\"select_catalog catalog_3_columns\" onchange=\"update_product_references(this)\">"
    html << options_for_product_reference_sub_categories(categories)
    html << "</select>"
  end
  
  def options_for_product_reference_sub_categories(categories)
    html = ""
    html << "<option style=\"font-weight:bold\" selected=\"selected\" value=\"0\">Il y a #{pluralize(categories.size, "sous-famille", "sous-familles")}</option>"
    html << categories.map{ |category| "<option value=\"#{category.id}\" title=\"Cette sous-famille contient #{pluralize(category.product_references_count, "produit référence", "produits référence")}\">#{category.reference} - #{category.name} (#{category.product_references_count})</option>" }.to_s
  end
  
  def select_for_product_references(categories)
    html = ""
    html << "<select id=\"select_product_references\" size=\"10\" multiple=\"multiple\" class=\"select_catalog catalog_3_columns\" onclick=\"update_end_products(this)\" >"
    html << options_for_product_references(categories)
    html << "</select>"
  end
  
  def options_for_product_references(product_references)
    html = ""
    html << "<option style=\"font-weight:bold\" selected=\"selected\" value=\"0\">Il y a #{pluralize(product_references.size, "produit reference", "produits reference")}</option>"
    html << product_references.map{ |product_reference| "<option value=\"#{product_reference.id}\" title=\"Ce produit référence contient #{pluralize(product_reference.end_products_count, "produit fini", "produits finis")}\">#{product_reference.reference} - #{product_reference.name} (#{product_reference.end_products_count})</option>" }.to_s
  end
  
end
