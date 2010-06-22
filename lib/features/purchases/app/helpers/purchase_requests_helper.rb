module PurchaseRequestsHelper
  
  def generate_contextual_menu_partial
    render :partial => 'purchase_requests/contextual_menu'
  end
  
  def display_purchase_request_cancel_button(request)
    return "" unless request.can_be_cancelled?
    link_to( image_tag( "cancel_16x16.png",
                        :alt => text = "Annuler cette demande d'achat",
                        :title => text ),
              purchase_request_cancel_form_path(request.id),
             :confirm => "Êtes-vous sûr ?" )
  end
  
  def generate_list_action(request)
  result = "#{purchase_request_link(request, :link_text => "")} " + display_purchase_request_cancel_button(request)
  end
  
  def display_request_supply_add_button(purchase_request)
    return "" unless is_form_view? 
   content_tag( :p, link_to_function "Ajouter une matiere premiere ou un consommable" do |page|
     page.insert_html :bottom, "purchase_request_supply_form", :partial => 'purchase_request_supplies/purchase_request_supply_in_one_line',
                                                 :object  => PurchaseRequestSupply.new,
                                                 :locals  => { :purchase_request => purchase_request }
     last_element = page['purchase_request_supply_form'].select('.resource').last
     last_element.visual_effect :highlight
   end )
  end
  
  def display_purchase_request_supplies_list(purchase_request)
    purchase_request_supplies = purchase_request.purchase_request_supplies
    html = "<div id=\"supplies\" class=\"resources\">"
    html << render(:partial => 'purchase_request_supplies/begin_table')
    html << render(:partial => 'purchase_request_supplies/purchase_request_supply_in_one_line', :collection => purchase_request_supplies, :locals => { :purchase_request => purchase_request })
    html << render(:partial => 'purchase_request_supplies/end_table')
    html << display_request_supply_add_button(purchase_request)
    html << "</div>"
  end
end
