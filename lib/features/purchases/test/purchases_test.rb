Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + '/fixtures/'

class Test::Unit::TestCase
  fixtures :all
  
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
