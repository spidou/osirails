Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures/"

class Test::Unit::TestCase
  
  fixtures :all
  
  def build_purchase_request_supply(supply_id = 1, quantity = 400, date = Date.today + 1.week)  
    {:supply_id => supply_id, :expected_quantity => quantity, :expected_delivery_date => date}
  end
  
  def build_purchase_request_supplies_for(purchase_request, counter)
  
    counter.times do |count|
      purchase_request.purchase_request_supplies.build(build_purchase_request_supply(counter, (rand(400) + 1)))
    end
    purchase_request
    
  end
  
  def create_purchase_request
  
    purchase_request = PurchaseRequest.new(:user_id => 1, :employee_id => 2, :service_id => 3)
    purchase_request = build_purchase_request_supplies_for(purchase_request, 2)
    purchase_request.save!
    flunk "purchase request should be saved" if purchase_request.new_record?
    flunk "purchase request supplies should be saved" if purchase_request.purchase_request_supplies.select(&:new_record?).any?
    return purchase_request
    
  end
  
  def create_cancelled_purchase_request
  
    purchase_request = create_purchase_request
    purchase_request.cancelled_by = 1
    purchase_request.cancelled_comment = "cancelled comment"
    purchase_request.cancel
    purchase_request
    
  end
  
  def cancelled_purchase_request_supply(purchase_request_supply)
  
    purchase_request_supply.cancelled_by = 1
    flunk "purchase request supply should be cancel and save" unless purchase_request_supply.cancel
    purchase_request_supply
    
  end
    
  def create_purchase_order(user_id, supplier_id)
  
    purchase_order = PurchaseOrder.new(:user_id => user_id,
                                      :supplier_id => supplier_id,
                                      :status => PurchaseOrder::STATUS_DRAFT,
                                      :created_at => Time.now)
    commodity = supplies(:first_commodity)
    consumable = supplies(:first_consumable)
    build_purchase_order_supplies(purchase_order, {:purchase_order_id => purchase_order.id, :supply_id => commodity.id, :quantity => 1000, :taxes => 50, :fob_unit_price => 12, :supplier_reference => "C.01012010", :supplier_designation => "First Purchase Order Supply"} )
    build_purchase_order_supplies(purchase_order, {:purchase_order_id => purchase_order.id, :supply_id => consumable.id, :quantity => 2000, :taxes => 70, :fob_unit_price => 3, :supplier_reference => "M.01012010", :supplier_designation => "Second Purchase Order Supply"} )
    purchase_order.save!
    return purchase_order
    
  end
  
  def create_association_with_purchase_order_draft(purchase_request_supply)
    
    first_purchase_order =  create_purchase_order(1, 2)
    first_request_order_supply = RequestOrderSupply.new({:purchase_request_supply_id => purchase_request_supply.id,
                                                          :purchase_order_supply_id => first_purchase_order.purchase_order_supplies.first.id})
    first_request_order_supply.save!

  end
  
  def create_association_with_purchase_order_confirmed(purchase_request_supply)
  
    second_purchase_order =  create_purchase_order(1, 3)  
    second_request_order_supply = RequestOrderSupply.new({:purchase_request_supply_id => purchase_request_supply.id,
                                                          :purchase_order_supply_id => second_purchase_order.purchase_order_supplies.first.id})
   
    second_request_order_supply.save!
    second_purchase_order.status = PurchaseOrder::STATUS_CONFIRMED
    second_purchase_order.save!
    
  end
  
  def create_association_with_purchase_order_for(purchase_request_supplies)
  
    create_association_with_purchase_order_draft(purchase_request_supplies.first)
    create_association_with_purchase_order_confirmed(purchase_request_supplies.last)
    
  end
  
  def create_associated_purchase_request_with_purchase_order(purchase_order)
    purchase_request = create_purchase_request
    counter = 0
    for purchase_order_supply in purchase_order.purchase_order_supplies
      unless purchase_order_supply.cancelled?
        request_order_supply = RequestOrderSupply.new({ :purchase_request_supply_id => purchase_request.purchase_request_supplies[counter].id,
                                                        :purchase_order_supply_id => purchase_order_supply.id } )
        flunk '"request_order_supply" failed to save when creating associated purchase_request with already existing "purchase_order"' unless request_order_supply.save!
        counter += 1
      end
    end
  end
  
  def build_purchase_order_supplies(purchase_order, attributes = {})
  
    pos_size = purchase_order.purchase_order_supplies.size
    default_attributes = {  :supply_id => supplies(:first_commodity).id,
                            :quantity => 100,
                            :taxes => 5.5,
                            :fob_unit_price => 8,
                            :supplier_reference => attributes[:supplier_reference],
                            :supplier_designation => attributes[:supplier_designation] }
    purchase_order.purchase_order_supplies.build(default_attributes.merge(attributes))
    flunk 'build of "purchase_order_supply" failed' unless pos_size +1
  end
  
  def create_a_draft_purchase_order(attributes = {})
  
    default_attributes = {  :user_id => users(:admin_user).id,
                            :supplier_id => thirds(:first_supplier).id }
    purchase_order = PurchaseOrder.new(default_attributes.merge(attributes))
    build_purchase_order_supplies( purchase_order, {  :supplier_reference => "C.01012010",
                                                      :supplier_designation => "First Purchase Order Supply" })
    build_purchase_order_supplies( purchase_order, {  :supply_id => supplies(:first_consumable).id,
                                                      :quantity => 200,
                                                      :taxes => 6,
                                                      :supplier_reference => "M.01012010",
                                                      :supplier_designation => "Second Purchase Order Supply" })
    build_purchase_order_supplies( purchase_order, {  :supply_id => supplies(:second_commodity).id,
                                                      :quantity => 300,
                                                      :taxes => 5,
                                                      :supplier_reference => "C.02012010",
                                                      :supplier_designation => "Third Purchase Order Supply",
                                                      :cancelled_by => purchase_order.user_id,
                                                      :cancelled_comment => "Cancelled for tests",
                                                      :cancelled_at => Time.now })
    flunk 'purchase_order failed to save when creating a draft purchase_order' unless purchase_order.save!
    purchase_order
    
  end
  
  def prepare_purchase_order_to_be_completed(purchase_order)
    purchase_order.parcels.build(  :previsional_delivery_date => (Date.today),
                                    :received_on => (Date.today) )
    purchase_order.parcels.first.build_delivery_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "delivery_document.gif")))
    purchase_order.parcels.first.parcel_items.build( :selected => "1",
                                                        :purchase_order_supply_id => purchase_order.purchase_order_supplies.first.id,
                                                        :quantity => (purchase_order.purchase_order_supplies.first.quantity) )
    purchase_order.parcels.first.parcel_items.build( :selected => "1",
                                                      :purchase_order_supply_id => purchase_order.purchase_order_supplies[1].id,
                                                      :quantity => (purchase_order.purchase_order_supplies[1].quantity) )
    flunk '"parcel failed" to be received when preparing "purchase_order" to be completed' unless purchase_order.parcels.first.receive
    flunk '"purchase_order" failed to save when preparing "purchase_order" to be completed' unless purchase_order.save!
    purchase_order.reload
    purchase_order.build_invoice_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "invoice_document.gif")))
    purchase_order
  end
end
