require_dependency 'supplier'

class Supplier
  def get_all_purchase_request_supplies
    PurchaseRequestSupply.get_all_pending_purchase_request_supplies.select{ |s| s.supply.suppliers.include?(self) }
  end
  
  def merge_purchase_request_supplies
    kept_purchase_request_supplies = get_all_purchase_request_supplies.group_by(&:supply_id)
    list_of_merged_purchase_request_supply = []
    kept_purchase_request_supplies.each do |key, value|
      quantities_sum = value.collect{ |purchase_request_supply| purchase_request_supply[:expected_quantity] }.sum
      list_of_merged_purchase_request_supply << PurchaseRequestSupply.new(:purchase_request_id => nil, :supply_id => key, :expected_quantity => quantities_sum, :expected_delivery_date => value.first.expected_delivery_date )
    end
    list_of_merged_purchase_request_supply
  end
end
