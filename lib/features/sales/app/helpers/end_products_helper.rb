module EndProductsHelper
  
  def display_end_products_list_in_survey_step(order, parent_navigator)
    html = render(:partial => 'survey_step/end_product', :collection => order.end_products.select{ |p| !p.new_record? },
                                                         :locals => { :parent_navigator => parent_navigator })
    html << render_new_end_products_list(order)
  end
  
  def render_new_end_products_list(order)
    new_end_products = order.end_products.select(&:new_record?)
    html =  "<div class=\"new_records\" id=\"new_end_products\" #{"style=\"display:none\"" if new_end_products.empty?}>"
    html << render(:partial => 'survey_step/end_product', :collection => new_end_products)
    html << "</div>"
  end
  
  def display_autocomplete_field_to_add_end_product_in_survey_step(order)
    default_value_for_autocomplete_field = "Cherchez un produit référence dans la base"
    
    html =  "<div id=\"survey_step_search_product_reference\">"
    html << hidden_field_tag('add_end_product_with_this_product_reference_id')
    html << label_tag(:product_reference_reference, "Nouveau produit :")
    html << custom_text_field_with_auto_complete( :product_reference, :reference,
                                                  { :value      => default_value_for_autocomplete_field,
                                                    :size       => 50,
                                                    :onkeydown  => "if (event.keyCode == 13) { return false; }",
                                                    :class      => :product_reference_reference_input,
                                                    :id         => :product_reference_reference },
                                                  { :update_id  => 'add_end_product_with_this_product_reference_id' } )
    html << "&nbsp;"
    
    #TODO replace link_to_remove by button_to_remove after migrating to Rails 2.2.1
    html << ( link_to_remote "Ajouter", :update     => :new_end_products,
                                        :position   => :bottom,
                                        :url        => { :controller => :survey_step, :action => :new },
                                        :method     => :get,
                                        :condition  => "parseInt($('add_end_product_with_this_product_reference_id').value) > 0",
                                        :with       => "'product_reference_id=' + $('add_end_product_with_this_product_reference_id').value",
                                        :complete   => "$('new_end_products').show();" +
                                                       "$('new_end_products').select('.end_product').last().scrollTo().show().highlight();" +
                                                       "initialize_autoresize_text_areas();" +
                                                       "$('add_end_product_with_this_product_reference_id').value = '';" +
                                                       "$('product_reference_reference').value = '#{default_value_for_autocomplete_field}';" ) #TODO $('id').value = ''; $('id').blur() => but it doesn't work!! how can I do this ?
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
