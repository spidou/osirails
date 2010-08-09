require 'test/test_helper'

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + '/fixtures/'

class Test::Unit::TestCase
  
  fixtures :all
  
  def build_purchase_request_supply(attributes = {})  
    default_attributes = {  :supply_id => supplies("first_commodity").id,
                            :expected_quantity => 400,
                            :expected_delivery_date => Date.today + 1.week }
    default_attributes.merge(attributes)
  end
  
  def build_purchase_request_supplies_for(purchase_request, counter)
    counter.times do |count|
      purchase_request.purchase_request_supplies.build(build_purchase_request_supply(:supply_id => count+1, :expected_quantity => (rand(400)+ 1)))
    end
    flunk 'Build of "purchase_request_supplies" failed' unless purchase_request.purchase_request_supplies.size == counter
    purchase_request
  end
  
  def create_purchase_request(parameters = {:number_of_purchase_request_supplies => 2}, attributes = {})
    default_attributes = {  :user_id => users("admin_user").id,
                            :employee_id => employees("john_doe").id,
                            :service_id => services("direction_general").id }
    purchase_request = PurchaseRequest.new(default_attributes.merge(attributes))
    purchase_request = build_purchase_request_supplies_for(purchase_request, parameters[:number_of_purchase_request_supplies])
    purchase_request.save!
    flunk "purchase request should be saved" if purchase_request.new_record?
    flunk "purchase request supplies should be saved" if purchase_request.purchase_request_supplies.select(&:new_record?).any?
    purchase_request
  end
  
  def create_cancelled_purchase_request
    purchase_request = create_purchase_request
    purchase_request.cancelled_by_id = users("admin_user")
    purchase_request.cancelled_comment = "cancelled comment"
    purchase_request.cancel
    flunk '"Purchase_request" cancellation failed' unless purchase_request.cancelled?
    purchase_request
  end
  
  def cancelled_purchase_request_supply(purchase_request_supply)
    purchase_request_supply.cancelled_by_id = users("admin_user")
    flunk "purchase request supply should be cancelled and saved" unless purchase_request_supply.cancel
    purchase_request_supply
  end
    
  def create_association_with_purchase_order_draft(purchase_request_supply)
    first_purchase_order =  create_purchase_order
    first_request_order_supply = RequestOrderSupply.new({ :purchase_request_supply_id => purchase_request_supply.id,
                                                          :purchase_order_supply_id => first_purchase_order.purchase_order_supplies.first.id})
    first_request_order_supply.save!
  end
  
  def create_association_with_purchase_order_confirmed(purchase_request_supply)
    second_purchase_order =  create_a_confirmed_purchase_order  
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
  
  def create_confirmed_purchase_order(user_id, supplier_id)
    purchase_order = create_purchase_order(user_id, supplier_id)
    purchase_order.build_quotation_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "quotation_document.gif")))
    flunk "Confirmation failed" unless purchase_order.confirm
    purchase_order
  end
  
  def build_purchase_order_supplies(purchase_order, attributes = {})
    pos_size = purchase_order.purchase_order_supplies.size
    default_attributes = {  :supply_id            => supplies(:first_commodity).id,
                            :quantity             => 100,
                            :taxes                => 5.5,
                            :fob_unit_price       => 8,
                            :supplier_reference   => "REF01",
                            :supplier_designation => "Designation Fournisseur" }
    purchase_order.purchase_order_supplies.build(default_attributes.merge(attributes))
    flunk 'build of "purchase_order_supply" failed' unless purchase_order.purchase_order_supplies.size == (pos_size + 1)
  end
  
  def fill_associated_pos_with_prs_ids_which_have_the_same_supply_id(purchase_order, purchase_request)
    purchase_request_supplies = purchase_request.purchase_request_supplies
    purchase_order.purchase_order_supplies.each{ |pos|
      pos.purchase_request_supplies_ids = ""
      purchase_request_supplies.each{ |prs|
        if prs.supply_id == pos.supply_id
          pos.purchase_request_supplies_ids += prs.id.to_s + "\;"
          purchase_request_supplies.reject{ |purchase_request_supply| purchase_request_supply == prs }
        end
      }
    }
    purchase_order.save!
  end
  
  def fill_associated_pos_with_prs_ids_which_have_the_same_supply_id_to_deselect(purchase_order, purchase_request)
    purchase_request_supplies = purchase_request.purchase_request_supplies
    purchase_order.purchase_order_supplies.each{ |pos|
      pos.purchase_request_supplies_deselected_ids = ""
      purchase_request_supplies.each{ |prs|
        if prs.supply_id == pos.supply_id
          pos.purchase_request_supplies_deselected_ids += prs.id.to_s + "\;"
          purchase_request_supplies.reject{ |purchase_request_supply| purchase_request_supply == prs }
        end
      }
    }
    purchase_order.save!
  end
  
  def build_purchase_order_supply(purchase_order, attributes = {})
    default_attributes = {  :supply_id => supplies("first_commodity").id,
                            :quantity => 100,
                            :taxes => 5.5,
                            :fob_unit_price => 8,
                            :supplier_reference => attributes[:supplier_reference],
                            :supplier_designation => attributes[:supplier_designation] }
    flunk '"Purchase_order_supply" failed to build' unless purchase_order.purchase_order_supplies.build(default_attributes.merge(attributes))
    flunk '"Purchase_order_supply" is not valid' unless purchase_order.purchase_order_supplies.last.valid?
  end
    
  def create_purchase_order(attributes = {})
    default_attributes = {  :user_id => users(:admin_user).id,
                            :supplier_id => thirds(:first_supplier).id }
    purchase_order = PurchaseOrder.new(default_attributes.merge(attributes))
    build_purchase_order_supply(purchase_order, { :quantity => 1000,
                                                  :taxes => 50,
                                                  :fob_unit_price => 12,
                                                  :supplier_reference => "C.01012010",
                                                  :supplier_designation => "First Purchase Order Supply"} )
    build_purchase_order_supply(purchase_order, { :supply_id => supplies("first_consumable").id,
                                                  :quantity => 2000,
                                                  :taxes => 70,
                                                  :fob_unit_price => 3,
                                                  :supplier_reference => "M.01012010",
                                                  :supplier_designation => "Second Purchase Order Supply"} )
    purchase_order.save!
    purchase_order
  end
  
  def create_a_draft_purchase_order(attributes = {})
    purchase_order = create_purchase_order(attributes)
    build_purchase_order_supply( purchase_order, {:supply_id => supplies("second_commodity").id,
                                                  :quantity => 300,
                                                  :taxes => 5,
                                                  :supplier_reference => "C.02012010",
                                                  :supplier_designation => "Third Purchase Order Supply",
                                                  :cancelled_by_id => purchase_order.user_id,
                                                  :cancelled_comment => "Cancelled for tests",
                                                  :cancelled_at => Time.now } )
    purchase_order.save!
    purchase_order
  end
  
  def create_a_confirmed_purchase_order(attributes = {})
    purchase_order = create_a_draft_purchase_order(attributes)
    purchase_order.build_quotation_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "quotation_document.gif")))
    flunk 'Confirmation failed' unless purchase_order.confirm
    purchase_order.reload
  end
  
  def create_a_processing_purchase_order(attributes = {})
    purchase_order = create_a_confirmed_purchase_order(attributes)
    purchase_order.parcels.build(  :status => Parcel::STATUS_PROCESSING_BY_SUPPLIER,
                                    :conveyance => "ship",
                                    :previsional_delivery_date => (Date.today + 10),
                                    :processing_by_supplier_since => Date.today)
    purchase_order.parcels.first.parcel_items.build( :selected => "1",
                                                      :purchase_order_supply_id => purchase_order.purchase_order_supplies.first.id,
                                                      :quantity => (purchase_order.purchase_order_supplies.first.quantity) )
    purchase_order.save!
    purchase_order
  end
  
  def prepare_purchase_order_to_be_completed(purchase_order)
    purchase_order.parcels.build(  :previsional_delivery_date => (Date.today),
                                    :received_on => (Date.today) )
    purchase_order.parcels.first.build_delivery_document( :purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "delivery_document.gif")) )
    purchase_order.parcels.first.parcel_items.build(  :selected => "1",
                                                      :purchase_order_supply_id => purchase_order.purchase_order_supplies.first.id,
                                                      :quantity => (purchase_order.purchase_order_supplies.first.quantity) )
    purchase_order.parcels.first.parcel_items.build(  :selected => "1",
                                                      :purchase_order_supply_id => purchase_order.purchase_order_supplies[1].id,
                                                      :quantity => (purchase_order.purchase_order_supplies[1].quantity) )
    flunk '"parcel failed" to be received when preparing "purchase_order" to be completed' unless purchase_order.parcels.first.receive
    flunk '"purchase_order" failed to save when preparing "purchase_order" to be completed' unless purchase_order.save!
    purchase_order.reload
    purchase_order.build_invoice_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "invoice_document.gif")))
    purchase_order
  end
  
  def build_parcel_item_for(parcel, purchase_order = nil)
    purchase_order = create_a_confirmed_purchase_order unless purchase_order
    parcel.status = Parcel::STATUS_PROCESSING_BY_SUPPLIER
    parcel.processing_by_supplier_since = Date.today
    parcel.parcel_items.build({ :purchase_order_supply_id => purchase_order.purchase_order_supplies.first.id,
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
  
  
  def create_valid_parcel
    parcel = Parcel.new
    parcel = build_parcel_item_for(parcel, nil)
    flunk "parcel should be saved" unless parcel.save!
    parcel
  end
  
  def processing_by_supplier_parcel
    parcel = Parcel.new
    parcel = build_parcel_item_for(parcel, nil)
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
#    parcel.build_delivery_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "delivery_document.gif")))
    parcel.delivery_document_attributes = [{:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "delivery_document.gif"))}]
    flunk "parcel should in received status" unless parcel.receive
    flunk "parcel should in received status" unless parcel.received?
    flunk 'parcel should have "delivery_document"' unless parcel.delivery_document
    parcel
  end
  
  def cancelled_parcel
    parcel = create_valid_parcel
    parcel.cancelled_comment = "cancelled parcel"
    flunk "parcel should be cancelled" unless parcel.cancel
    flunk "parcel should be cancelled" unless parcel.cancelled?
    parcel
  end
  
  def create_a_purchase_order_supply_reported_for(parcel_item)
    parcel_item.must_be_reshipped = "1"
    parcel_item.issues_comment = "purchase_order_supply reported"
    parcel_item.issues_quantity = parcel_item.quantity
    flunk "parcel_item should be reported" unless parcel_item.report
    flunk "issue_purchase_order_supply should be create" if parcel_item.issue_purchase_order_supply.new_record?
    parcel_item.issue_purchase_order_supply
  end
end
