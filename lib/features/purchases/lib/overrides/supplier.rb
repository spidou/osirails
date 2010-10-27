require_dependency 'supplier'

class Supplier
  def all_purchase_request_supplies
    PurchaseRequestSupply.all_pending_purchase_request_supplies.select{ |s| s.supply and s.supply.suppliers.include?(self) }.compact
  end
  
  def merge_purchase_request_supplies
    kept_purchase_request_supplies = all_purchase_request_supplies.group_by(&:supply_id)
    list_of_merged_purchase_request_supply = []
    kept_purchase_request_supplies.each do |key, value|
      quantities_sum = value.collect{ |purchase_request_supply| purchase_request_supply[:expected_quantity] }.sum
      list_of_merged_purchase_request_supply << PurchaseRequestSupply.new(:purchase_request_id => nil, :supply_id => key, :expected_quantity => quantities_sum, :expected_delivery_date => value.first.expected_delivery_date )
    end
    list_of_merged_purchase_request_supply
  end
  
  def longest_lead_time 
    merged_purchase_request_supplies = self.merge_purchase_request_supplies
    longest_lead_time = 0
    for merged_purchase_request_supply in merged_purchase_request_supplies
      if supplier_supply = merged_purchase_request_supply.supply.supplier_supplies.first(:conditions => ['supplier_id = ?', self.id])
        longest_lead_time = supplier_supply.lead_time if supplier_supply.lead_time and supplier_supply.lead_time > longest_lead_time
      end
    end
    longest_lead_time
  end
  
  def purchase_request_supplies_total
    merged_purchase_request_supplies = self.merge_purchase_request_supplies
    totals_sum = 0
    for merged_purchase_request_supply in merged_purchase_request_supplies
      supplier_supply = merged_purchase_request_supply.supply.supplier_supplies.first(:conditions => ['supplier_id = ?', self.id])
      totals_sum += (supplier_supply.fob_unit_price * ((100 + supplier_supply.taxes ) / 100)) * merged_purchase_request_supply.expected_quantity
    end
    totals_sum
  end
  
end
