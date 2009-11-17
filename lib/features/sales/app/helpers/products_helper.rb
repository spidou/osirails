module ProductsHelper
  
  def display_products_list_in_survey_step(order)
    html = render(:partial => 'survey_step/product', :collection => order.products.select{ |p| !p.new_record? })
    html << render_new_products_list(order)
  end
  
  def render_new_products_list(order)
    new_products = order.products.select(&:new_record?)
    html =  "<div class=\"new_records\" id=\"new_products\" #{"style=\"display:none\"" if new_products.empty?}>"
    html << render(:partial => 'survey_step/product', :collection => new_products)
    html << "</div>"
  end
  
  def display_autocomplete_field_to_add_product_in_survey_step(order)
    default_value_for_autocomplete_field = "Cherchez un produit référence dans la base"
    
    html =  "<div class=\"survey_step_search_product_reference\">"
    html << hidden_field_tag('add_product_with_this_product_reference_id')
    html << label_tag(:product_reference_reference, "Nouveau produit :")
    html << custom_text_field_with_auto_complete( :product_reference, :reference,
                                                  { :value      => default_value_for_autocomplete_field,
                                                    :size       => 50,
                                                    :onkeydown  => "if (event.keyCode == 13) { return false; }" },
                                                  { :update_id  => 'add_product_with_this_product_reference_id' } )
    html << "&nbsp;"
    
    #TODO replace link_to_remove by button_to_remove after migrating to Rails 2.2.1
    html << ( link_to_remote "Ajouter", :update     => :new_products,
                                        :position   => :bottom,
                                        :url        => { :controller => :survey_step, :action => :new },
                                        :method     => :get,
                                        :condition  => "parseInt($('add_product_with_this_product_reference_id').value) > 0",
                                        :with       => "'product_reference_id=' + $('add_product_with_this_product_reference_id').value",
                                        :complete   => "$('new_products').show();" +
                                                       "$('new_products').select('.product').last().scrollTo().show().highlight();" +
                                                       "initialize_autoresize_text_areas();" +
                                                       "initialize_tab_navigation();" +
                                                       "$('add_product_with_this_product_reference_id').value = '';" +
                                                       "$('product_reference_reference').value = '#{default_value_for_autocomplete_field}';" ) #TODO $('id').value = ''; $('id').blur() => but it doesn't work!! how can I do this ?
    html << "</div>"
  end
  
  def display_anchor_to_autocomplete_field_to_add_product_in_survey_step
    content_tag(:p, link_to_function "Nouveau produit" do |page|
      page['survey_step'].scrollTo;
      page['product_reference_reference'].up('.survey_step_search_product_reference').highlight
      page['product_reference_reference'].select
    end )
  end
  
  def display_product_delete_button_in_survey_step(product)
    confirm = "Êtes-vous sûr ? Cela aura pour conséquence de supprimer tout ce qui est en relation directe avec ce produit. Attention, les modifications seront appliquées à la soumission du forumulaire."
    link_to_function "Supprimer", "if (confirm(\"#{confirm}\")) mark_resource_for_destroy(this)"
  end
  
end
