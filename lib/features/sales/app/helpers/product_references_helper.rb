module ProductReferencesHelper
  # This method permit to show all references
  def show_reference(categories)
    count = categories.select(&:enabled?).collect(&:product_references_count).sum
    select_header = pluralize(count, 'reference', 'references')
    
    show_references = []
    show_references << "<option value=\"0\" selected=\"selected\" style=\"font-weight:bold\">Il y a #{select_header}</option>"
    show_references += categories.collect{ |category| get_show_reference(category) }
    show_references.to_s
  end

  # This method permit to have all references for a category and this children
  def get_show_reference(category)
    show_references = []
    if category.product_reference_categories.any?
      category.product_reference_categories.each do |child_category|
        if child_category.product_reference_categories.any? or child_category.product_references.any?
          show_references << get_show_reference(child_category)
        end
      end
    end
    
    if category.product_references.any?
      category.product_references.each do |reference|
        show_references << "<option value=\"#{reference.id}\">#{reference.name} (#{reference.end_products_count})</option>"
      end
    end
    show_references.reverse
  end
  
end
