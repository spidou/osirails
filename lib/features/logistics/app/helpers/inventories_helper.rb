module InventoriesHelper
  def new_inventory_link(supply, text = nil)
    if Inventory.can_add?(current_user)
      text ||= "Nouvel inventaire"
      link_to(image_tag( "add_16x16.png", :alt => text, :title => text )+ " " + text, new_inventory_path(:supply_class => supply.class.name))
    end
  end

  def supplier_supply(supplier,supply)
    SupplierSupply.find_by_supply_id_and_supplier_id(supply.id,supplier.id)
  end
end

