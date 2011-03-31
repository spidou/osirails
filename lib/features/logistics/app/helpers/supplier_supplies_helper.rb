module SupplierSuppliesHelper  
  def display_supplier_supply_list(supply)
    render :partial => 'supplier_supplies/supplier_supplies', :object => supply.supplier_supplies,
                                                              :locals => { :supply => supply }
  end
  
  def display_supplier_supply_add_button(supply)
    link_to_function "Ajouter un fournisseur" do |page|
      page.insert_html :bottom, :supplier_supplies_body, :partial => 'supplier_supplies/supplier_supply_in_one_line', :object => SupplierSupply.new,
                                                                                                                      :locals => { :supply => supply }
    end
  end
end
