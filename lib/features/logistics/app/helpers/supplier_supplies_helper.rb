module SupplierSuppliesHelper  
  def display_supplier_supply_list(supply)
    return unless SupplierSupply.can_list?(current_user)
    
    html = ""
    unless supply.supplier_supplies.empty?
      html << render(:partial => 'supplier_supplies/supplier_supplies', :object => supply.supplier_supplies,
                                                                        :locals => { :supply => supply })
    else
      html << "<p>Aucun fournisseur n'a été trouvé</p>"
    end
    html
  end
  
  def display_supplier_supply_add_button(supply)
    return unless SupplierSupply.can_add?(current_user)
    
    link_to_function "Ajouter un fournisseur" do |page|
      page.insert_html :bottom, :supplier_supplies_body, :partial => 'supplier_supplies/supplier_supply_in_one_line', :object => SupplierSupply.new,
                                                                                                                      :locals => { :supply => supply }
    end
  end
end
