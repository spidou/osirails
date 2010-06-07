module PurchaseRequestsHelper
  
  def generate_contextual_menu_partial
    render :partial => 'purchase_requests/contextual_menu'
  end
  
  def generate_list_action(request)
  result = "#{purchase_request_link(request, :link_text => "")} #{delete_purchase_request_link(request, :link_text => "")}"
  end
  
  def display_purchase_request_supplies_list(purchase_request)
    purchase_request_supplies = purchase_request.purchase_request_supplies
    html = "<div id=\"supplies\" class=\"resources\">"
    unless purchase_request_supplies.empty?
      html << render (:partial => 'purchase_request_supplies/purchase_request_supply_in_one_line', :collection => purchase_request_supplies, :locals => { :purchase_request => purchase_request })
    else
      html << "<p>Veuillez selectionné un ou des produit(s)</p>"
    end
    html << "</div>"
  end
end
