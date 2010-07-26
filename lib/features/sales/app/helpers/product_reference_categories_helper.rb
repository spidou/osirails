module ProductReferenceCategoriesHelper
  
  # This method permit to show a category and its children
  def show_category(categories)
    sub_categories = categories.select(&:enabled?).collect(&:children).flatten
    count = sub_categories.size
    
    select_header = pluralize(count, "sous-famille", "sous-familles")
    html = "<option value=\"0\" selected=\"selected\" style=\"font-weight:bold\">Il y a #{select_header}</option>"
    
    html << sub_categories.map{ |s| "<option value=\"#{s.id}\">#{s.name} (#{s.product_references_count})</option>" }.to_s
  end
  
end
