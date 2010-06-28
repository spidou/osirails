module PurchaseRequestSuppliesHelper
  
  def display_associated_purchase_order(purchase_request_supply)
    return "Aucun" unless associated_purchase_order_supply = purchase_request_supply.confirmed_purchase_order_supply
    link_to(associated_purchase_order_supply.purchase_order.reference, purchase_order_path(associated_purchase_order_supply.purchase_order))
  end

end
