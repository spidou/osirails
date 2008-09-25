module ProductReferencesHelper

  # This method permit to show all references
  def show_reference(categories)
    show_references = []
    count = 0
    
    categories.each do |category|
      if category.enable == true
        count += category.product_references_count
      end
      count
    end
    
    select_header = pluralize(count, 'reference', 'references')
    show_references << "<option value=\"0\" selected=\"selected\" style=\"font-weight:bold\">Il y a #{select_header}</option>"
      
    categories.each do |category|
      show_references << get_show_reference(category)
    end
    show_references
  end

  # This method permit to have all references for a category and this children
  def get_show_reference(category)
    show_references = []
    if category.children.size != 0
      categories = ProductReferenceCategory.find(:all, :order => 'product_reference_category_id', :conditions => {:enable => true, :product_reference_category_id => category.id}).reverse
      categories.each do |category_child|
        if category_child.children.size != 0 or category_child.product_references.size != 0
          show_references << get_show_reference(category_child)
        end
      end
    end
    if category.product_references.size > 0
      references = ProductReference.find(:all, :order => 'product_reference_category_id', :conditions => {:enable => true, :product_reference_category_id => category.id}).reverse
      references.each do |reference|
        show_references << "<option value=\"#{reference.id}\">"+reference.name+" (#{reference.products_count})</option>"
      end
    end
    show_references.reverse
  end

end
