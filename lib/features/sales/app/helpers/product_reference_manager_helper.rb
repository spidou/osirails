module ProductReferenceManagerHelper
  
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
  
end
