module InventoriesHelper
  def inventory_link(supply,date, text=nil)
    if Inventory.can_add?(current_user)
      text ||= "Voir" 
      #"Show #{supply.class.name.tableize}"
      link_to(image_tag( "/images/view_16x16.png", :alt => text, :title => text ), "/inventories/show?type="+supply.class.name+"&date="+date.to_s.to_date.strftime("%d-%m-%Y"))
    end
  end

  def new_inventory_link(supply, text=nil)
    if Inventory.can_add?(current_user)
      text ||= "Nouveau"
      #"New #{supply.class.name.tableize} inventory"
      link_to(image_tag( "/images/add_16x16.png", :alt => text, :title => text )+ " " + text, "/inventories/new?type="+supply.class.name)
    end
  end

  def supplier_supply(supplier,supply)
    SupplierSupply.find_by_supply_id_and_supplier_id(supply.id,supplier.id)
  end
end

