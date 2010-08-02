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
    flunk "purchase request should be save" if purchase_request.new_record?
    flunk "purchase request supplies should be save" if purchase_request.purchase_request_supplies.select(&:new_record?).any?
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
  
  def create_confirmed_purchase_order(user_id, supplier_id)
    purchase_order = create_purchase_order(user_id, supplier_id)
    purchase_document_build(purchase_order, :purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "quotation_document.gif")))
    flunk "Confirmation failed" unless purchase_order.confirm
    purchase_order
  end
  
  def build_purchase_order_supplies(purchase_order, attributes = {})
    purchase_order.purchase_order_supplies.build({:supply_id => attributes[:supply_id],
                                                  :cancelled_by => attributes[:cancelled_by],
                                                  :quantity => attributes[:quantity],
                                                  :taxes => attributes[:taxes],
                                                  :fob_unit_price => attributes[:fob_unit_price],
                                                  :supplier_reference => attributes[:supplier_reference],
                                                  :supplier_designation => attributes[:supplier_designation],
                                                  :cancelled_comment => attributes[:cancelled_comment],
                                                  :cancelled_at => attributes[:cancelled_at],
                                                  :created_at => attributes[:created_at],
                                                  :updated_at => attributes[:updated_at]
                                                  })
  end
    
  def destroy_all_purchase_order_supplies(purchase_order)
    for purchase_order_supply in purchase_order.purchase_order_supplies
      purchase_order_supply.destroy
    end
    purchase_order.purchase_order_supplies.reload
    flunk "Destruction failed" unless purchase_order.purchase_order_supplies.empty?
  end
  
  def purchase_document_build(purchase_order, attributes)
    purchase_order.build_quotation_document(attributes)
  end
  
  def build_parcel_item_for(parcel)
    purchase_order = create_confirmed_purchase_order(1, 2)
    parcel.status = Parcel::STATUS_PROCESSING_BY_SUPPLIER
    parcel.processing_by_supplier_since = Date.today
    parcel.parcel_items.build({:purchase_order_supply_id => purchase_order.purchase_order_supplies.first.id,
                                :quantity => purchase_order.purchase_order_supplies.first.quantity,
                                :selected => "1"})
    parcel                       
  end 
  
  def put_received_status_for(parcel)
    parcel.received_on = Date.today
    parcel.build_delivery_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "delivery_document.gif")))
    flunk "parcel should be put in received status" unless parcel.receive
    parcel
  end
  
  def build_parcel
    Parcel.new
  end
  
  def create_parcel
    parcel = build_parcel
  end
  
  def create_valid_parcel
    parcel = create_parcel
    parcel = build_parcel_item_for(parcel)
    flunk "parcel should be saved" unless parcel.save!
    parcel
  end
  
  def processing_by_supplier_parcel
    parcel = create_parcel
    parcel = build_parcel_item_for(parcel)
    flunk "parcel should in processing_by_supplier_parcel status" unless parcel.process_by_supplier
    flunk "parcel should in processing_by_supplier_parcel status" unless parcel.processing_by_supplier?
    parcel
  end
  
  def shipped_parcel
    parcel = create_valid_parcel
    parcel.shipped_on = Date.today
    parcel.conveyance = "par avion"
    flunk "parcel should in shipped status" unless parcel.ship
    flunk "parcel should in shipped status" unless parcel.shipped?
    parcel
  end
  
  def received_by_forwarder_parcel
    parcel = create_valid_parcel
    parcel.received_by_forwarder_on = Date.today
    flunk "parcel should be in received_by_forwarder status" unless parcel.receive_by_forwarder
    flunk "parcel should be in received_by_forwarder status" unless parcel.received_by_forwarder?
    parcel
  end  
  
  def received_parcel
    parcel = create_valid_parcel
    parcel.received_on = Date.today
    parcel.build_delivery_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "delivery_document.gif")))
    flunk "parcel should in received status" unless parcel.receive
    flunk "parcel should in received status" unless parcel.received? 
    parcel
  end
  
  def cancelled_parcel
    parcel = create_valid_parcel
    parcel.cancelled_comment = "cancelled parcel"
    flunk "parcel should be cancelled" unless parcel.cancel
    flunk "parcel should be cancelled" unless parcel.cancelled?
    parcel
  end
  
end
