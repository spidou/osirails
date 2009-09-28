module SupplierSuppliesHelper  
  def display_supplier_supply_list(owner)
    return unless SupplierSupply.can_list?(current_user)
    
    html = "<h2>Fournisseurs</h2>"
    html << "<div id=\"supplier_supplies\">"
    unless owner.supplier_supplies.empty?
      html << render(:partial => 'supplier_supplies/supplier_supplies', :locals => { :supplier_supplies_owner => owner }) unless is_form_view?
      html << render(:partial => 'supplier_supplies/supplier_supply_in_one_line', :collection => owner.supplier_supplies, :locals => { :supplier_supplies_owner => owner } )
    else
      html << "<p>Aucun fournisseur n'a été trouvé</p>"
    end
    html << "</div>"
  end
  
  def display_supplier_supply_add_button(owner)
    return unless SupplierSupply.can_add?(current_user)
    
    link_to_function "Ajouter un fournisseur" do |page|
      page.insert_html :bottom, :supplier_supplies, :partial => 'supplier_supplies/supplier_supply_form', :object => SupplierSupply.new, :locals => { :supplier_supplies_owner => owner }
    end
  end
  
  def new_stock_flow_link(input,supplier_supply)
    if "Stock#{input ? 'Input' : 'Output'}".constantize.can_add?(current_user)
      text = " New stock #{input ? 'input' : 'output'}"
      link_to(image_tag( "/images/arrow_#{input ? 'up' : 'down'}_16x16.png", :alt => text, :title => text ), "/stock_#{input ? 'inputs' : 'outputs'}/new?supply_id=#{supplier_supply.supply.id}&supplier_id=#{supplier_supply.supplier.id}")
    end
  end  
end
