Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures/"

class Test::Unit::TestCase
  
  fixtures :all
  
  def create_purchase_request
    purchase_request = purchase_requests(:first_purchase_request)
    if purchase_request.purchase_request_supplies.empty?
      purchase_request.purchase_request_supplies.build(purchase_request_supplies(:first_purchase_request_supply).attributes)
      purchase_request.purchase_request_supplies.build(purchase_request_supplies(:second_purchase_request_supply).attributes)
    end
    purchase_request.purchase_request_supplies[0].expected_delivery_date = nil
    purchase_request.global_date = Date.today + 1.week
    purchase_request.purchase_request_supplies = purchase_request.update_date
    purchase_request.save!
    flunk "purchase_request should be saved" if purchase_request.new_record?
    flunk "purchase_request_supplies should be saved" if purchase_request.purchase_request_supplies.select(&:new_record?).any?
    return purchase_request
  end
  
  def create_purchase_request_and_cancel
    purchase_request = purchase_requests(:first_purchase_request)
    purchase_request.purchase_request_supplies.build(purchase_request_supplies(:first_purchase_request_supply).attributes)
    purchase_request.save!
    purchase_request.cancelled_by = 1
    purchase_request.cancelled_comment  = "purchase_request is cancelled"
    purchase_request.cancel
    purchase_request
  end
  
  def create_first_purchase_order
    purchase_order = purchase_orders(:first_purchase_order)
    if purchase_order.purchase_order_supplies.empty?
      purchase_order.purchase_order_supplies.build(purchase_order_supplies(:first_purchase_order_supply).attributes)
      purchase_order.purchase_order_supplies.build(purchase_order_supplies(:second_purchase_order_supply).attributes)
    end
    if !purchase_order.purchase_order_supplies.first
      if !SupplierSupply.find_by_supply_id_and_supplier_id(purchase_order_supplies.first.supply_id, purchase_order.supplier_id)
        supplier_supply.build(supplier_supplies(:first_supplier_supply).attributes)
      end
    end
    if !purchase_order.purchase_order_supplies[1]
      if !SupplierSupply.find_by_supply_id_and_supplier_id(purchase_order_supplies[1].supply_id, purchase_order.supplier_id)
        supplier_supply.build(supplier_supplies(:second_supplier_supply).attributes)
      end
    end
    purchase_order.save
    return purchase_order
  end
  
end
