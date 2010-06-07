module RequestSuppliesHelper
  
  def display_request_supply_add_button(purchase_request)
    
    content_tag( :p, link_to_function "Ajouter une matiere premier ou un consommable" do |page|
      page.insert_html :bottom, :purchase_request_supplies, :partial => 'purchase_request_supplies/purchase_request_supply',
                                                 :object  => PurchaseRequestSupply.new,
                                                 :locals  => { :purchase_request => purchase_request }
      #last_element = page['establishments'].select('.resource').last
      last_element.visual_effect :highlight
    end )
  end
end
