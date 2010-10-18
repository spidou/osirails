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
    content_tag( :p, link_to_function "Ajouter une fourniture" do |page|
      page.insert_html :bottom, "purchase_request_supply_form", :partial => 'purchase_request_supplies/purchase_request_supply_in_one_line',
                                                                :object  => PurchaseRequestSupply.new,
                                                                :locals  => { :purchase_request => purchase_request }
      last_element = page['purchase_request_supply_form'].select('.resource').last
      last_element.visual_effect "highlight" # :highlight symbol replaced by "highlight" string to relieve to the "undefined method `ascii_only?' for {}:Hash" error, in views
    end )
  end
  
  def display_purchase_request_supplies_list(purchase_request)
    purchase_request_supplies = purchase_request.purchase_request_supplies
    html = "<div id=\"supplies\" class=\"resources\">"
    html << render(:partial => 'purchase_request_supplies/begin_table', :locals => { :purchase_request => purchase_request })
    html << render(:partial => 'purchase_request_supplies/purchase_request_supply_in_one_line', :collection => purchase_request_supplies, :locals => { :purchase_request => purchase_request }) if purchase_request_supplies.any?
    html << render(:partial => 'purchase_request_supplies/end_table', :locals => { :purchase_request => purchase_request })
    html << "</div>"
  end
  
  def display_active_purchase_requests_having_this_supply(supply)
    html = []
    PurchaseRequest.all.select(&:active?).select{ |pr| pr.purchase_request_supplies.detect{ |prs| prs.supply_id == supply.id } }.each do |pr|
      html << link_to(pr.reference, purchase_request_path(pr))
    end
    html.join("<br />")
  end
  
  def display_status_for(purchase_request)
    total_quantity_of_supplies = purchase_request.purchase_request_supplies.size
    return "Annulée" if purchase_request.cancelled? 
    return "Non traitée" if purchase_request.untreated_purchase_request_supplies.size == total_quantity_of_supplies
    return "En cours de traitement" if purchase_request.during_treatment_purchase_request_supplies.any?
    return "Partiellement traitée" if partially_treated_purchase_request_supplies?
    return "Traitée" if purchase_request.treated_purchase_request_supplies.size == total_quantity_of_supplies
  end
  
end
