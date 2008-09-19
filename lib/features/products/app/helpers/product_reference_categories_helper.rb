module ProductReferenceCategoriesHelper
  
  # This method permit to show category and this children
  def show_category(categories)
    show_categories = []
    count = 0
    
    categories.each do |category|
      if category.enable == true
        count += category.children.size
      end
      count
    end
    
    select_header = pluralize(count, "sous-famille", "sous-familles")
    show_categories << "<option value=\"0\" selected=\"selected\">Il y a #{select_header}</option>"
    
    categories.each do |category|
      if category.children.size != 0
        categories = ProductReferenceCategory.find(:all, :order => 'product_reference_category_id', :conditions => {:enable => true, :product_reference_category_id => category.id})
        categories.each do |category_child|
          show_categories << "<option value=\"#{category_child.id}\"}>"+category_child.name+" (#{category_child.product_references_count})</option>"
        end
      end
    end
    show_categories
  end
  
end
