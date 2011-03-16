module EndProductsHelper
  
  def display_end_products_list_in_survey_step(order, parent_navigator)
    saved_end_products = order.end_products.reject(&:new_record?)
    html = ""
    html << render(:partial => 'survey_step/end_product', :collection => saved_end_products,
                                                          :locals => { :parent_navigator => parent_navigator }) if saved_end_products.any?
    html << render_new_end_products_list(order)
  end
  
  def render_new_end_products_list(order)
    new_end_products = order.end_products.select(&:new_record?)
    html =  "<div class=\"new_records\" id=\"new_end_products\" #{"style=\"display:none\"" if new_end_products.empty?}>"
    html << render(:partial => 'survey_step/end_product', :collection => new_end_products) unless new_end_products.empty?
    html << "</div>"
  end
  
  def display_autocomplete_field_to_add_end_product_in_survey_step(order)
    default_value_for_autocomplete_field = "Cherchez un produit référence dans la base"
    
    html =  "<div id=\"survey_step_search_product_reference\">"
    html << label_tag(:product_reference_reference, "Nouveau produit :")
    html << custom_text_field_with_auto_complete( :product_reference, :reference,
                                                  { :value      => default_value_for_autocomplete_field,
                                                    :size       => 50,
                                                    :onkeydown  => "if (event.keyCode == 13) { return false; }",
                                                    :class      => :product_reference_reference_input,
                                                    :id         => :product_reference_reference },
                                                  { :with => "value+'&only=product_references'" } )
    html << "&nbsp;"
    html << tag(:input, :type => :button, :value => "Ajouter", :class => :add_item, 'data-field-id' => :product_reference_reference, 'data-remote-path' => new_order_commercial_step_survey_step_path(order) , 'data-token' => form_authenticity_token)
    html << "</div>"
  end
  
  def display_anchor_to_autocomplete_field_to_add_end_product_in_survey_step
    content_tag(:p, link_to_function "Nouveau produit" do |page|
      page['survey_step'].scrollTo;
      page['survey_step_search_product_reference'].highlight
      page['survey_step_search_product_reference'].down('.product_reference_reference_input').select
    end )
  end
  
  def display_end_product_delete_button_in_survey_step(end_product)
    return unless end_product.can_be_deleted?
    confirm = "Êtes-vous sûr ? Cela aura pour conséquence de supprimer tout ce qui est en relation directe avec ce produit. Attention, les modifications seront appliquées à la soumission du formulaire."
    link_to_function "Supprimer", "if (confirm(\"#{confirm}\")) mark_resource_for_destroy(this)"
  end
  
end
