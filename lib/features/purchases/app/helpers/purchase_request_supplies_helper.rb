module PurchaseRequestSuppliesHelper
  
  def display_associated_purchase_order(purchase_request_supply)
    return "Aucun" unless associated_purchase_order_supply = purchase_request_supply.confirmed_purchase_order_supply
    link_to(associated_purchase_order_supply.purchase_order.reference, purchase_order_path(associated_purchase_order_supply.purchase_order))
  end
  
  def check_request_supply_status(purchase_request_supply)
    return "non traité" if purchase_request_supply.untreated?  
    return "en cours de traitement" if purchase_request_supply.during_treatment? 
    return "traité" if purchase_request_supply.treated? 
  end
  
end
