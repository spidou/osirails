require 'test/test_helper'

require 'lib/features/sales/test/unit/product_base_test'
require 'lib/features/sales/test/unit/quote_base_test'

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + '/fixtures/'

class Test::Unit::TestCase
  
  fixtures :all

# *************************        supplier       ****************************************

  def create_supplier(fixture_model = thirds("first_supplier"))
    supplier = fixture_model
    supplier.activity_sector_reference=(activity_sector_references("ref999"))
    supplier.legal_form=(legal_forms("llc"))
    supplier.save!
    create_supplier_contact(supplier)
    supplier
  end

  def create_supplier_contact(supplier)
    supplier.contacts.build( :first_name  => "Pierre Paul",
                             :last_name   => "Jacques",
                             :job         => "Commercial",
                             :email       => "pierre_paul@jacques.com",
                             :gender      => "M")
     supplier.save!
  end
  
# *************************   quotation_request   ****************************************

  def create_drafted_quotation_request(args = {})
    supplier = create_supplier
    create_supplier_contact(supplier)
    quotation_request = QuotationRequest.new
    quotation_request.creator_id = users("admin_user").id
    quotation_request.supplier_id = supplier.id
    quotation_request.supplier_contact_id = supplier.contacts.first.id
    if args[:quotation_request_supplies_attributes]
      build_quotation_request_supplies(quotation_request, :quotation_request_supplies_attributes => args[:quotation_request_supplies_attributes])
    else
      build_quotation_request_supplies(quotation_request)
    end
    quotation_request.save!
    quotation_request
  end

  def create_confirmed_quotation_request(args = {})
    quotation_request = create_drafted_quotation_request(args)
    quotation_request.employee_id = employees("john_doe").id
    flunk 'Failed to confirm the quotation_request' unless quotation_request.confirm
    quotation_request
  end

  def create_terminated_quotation_request(args = {})
    quotation_request = create_confirmed_quotation_request(args)
    quotation = quotation_request.build_prefilled_quotation
    flunk 'Failed to build the quotation' unless quotation
    make_quotation_valid(quotation)
    quotation.signed_on = Date.today - 1
    quotation.sent_on = Date.today
    flunk 'Failed to send the quotation' unless quotation.send_to_supplier
    flunk 'Failed to terminate the quotation_request' unless quotation_request.terminated?
    quotation_request
  end

  def create_cancelled_quotation_request(args = {})
    quotation_request = create_confirmed_quotation_request(args)
    quotation_request.cancellation_comment = "Cancelled for tests"
    quotation_request.canceller_id = users("admin_user").id
    flunk 'Failed to cancel the quotation_request' unless quotation_request.cancel
    quotation_request
  end

  def create_revoked_quotation_request(args = {})
    similar_quotation_request = create_confirmed_quotation_request(args)
    quotation_request = similar_quotation_request.build_prefilled_similar
    
    second_supplier = create_supplier(thirds("second_supplier"))
    create_supplier_contact(second_supplier)
    
    quotation_request.supplier_id = second_supplier.id
    quotation_request.creator_id = users("admin_user").id
    quotation_request.supplier_contact_id = second_supplier.contacts.first.id
    quotation_request.employee_id = employees("john_doe").id
    quotation_request.save!
    
    similar_quotation_request.build_prefilled_quotation
    
    make_quotation_valid(similar_quotation_request.quotation)
    similar_quotation_request.quotation.signed_on = Date.today
    flunk 'Failed to sign the quotation' unless similar_quotation_request.quotation.sign
    quotation_request.reload
    flunk 'Failed to revoke the quotaton_request' unless quotation_request.revoked?
    quotation_request
  end
  
  def prepare_quotation_request_to_be_confirmed(quotation_request)
    quotation_request.employee_id = employees("john_doe").id
    flunk 'Quotation_request confirmed_at failed to be initialized' unless quotation_request.confirmed_at = Time.now
    flunk 'Quotation_request status failed to be set to confirmed unless' unless quotation_request.status = QuotationRequest::STATUS_CONFIRMED
    quotation_request
  end

# ************************* quotation_request_supply *************************************
  
  def build_quotation_request_supplies(quotation_request, args = {})
    if args[:quotation_request_supplies_attributes]
      args[:quotation_request_supplies_attributes].each do |qrs_attributes|
        if qrs_attributes[:supply_id]
          qrs_attributes[:position] ||= ( quotation_request.quotation_request_supplies.last && quotation_request.quotation_request_supplies.last.position.to_i + 1 ) || 0
          qrs_attributes[:supplier_reference] ||= SupplierSupply.first("supplier_id = ? and supply_id = ?", quotation_request.supplier_id, qrs_attributes[:supply_id] ).supplier_reference
          qrs_attributes[:supplier_designation] ||= SupplierSupply.first("supplier_id = ? and supply_id = ?", quotation_request.supplier_id, qrs_attributes[:supply_id] ).supplier_designation
          build_existing_quotation_request_supply(quotation_request, qrs_attributes)
        elsif !qrs_attributes[:comment_line]
          build_free_quotation_request_supply(quotation_request, qrs_attributes)
        else
          build_comment_line_for_quotation_request(quotation_request, qrs_attributes)
        end
      end
    else
      build_existing_quotation_request_supply(quotation_request)
    end
    quotation_request.quotation_request_supplies
  end
  
  def build_existing_quotation_request_supply(quotation_request, attributes = {})
    initial_size = quotation_request.quotation_request_supplies.size
    default_attributes = {:quantity => 1000,
                          :position => ( quotation_request.quotation_request_supplies.last && quotation_request.quotation_request_supplies.last.position.to_i + 1 ) || 0,
                          :supply_id => supplies("first_commodity").id,
                          :designation => supplies("first_commodity").name,
                          :supplier_reference => SupplierSupply.first("supplier_id = ? and supply_id = ?", quotation_request.supplier_id, supplies("first_commodity").id ).supplier_reference,
                          :supplier_designation => SupplierSupply.first("supplier_id = ? and supply_id = ?", quotation_request.supplier_id, supplies("first_commodity").id ).supplier_designation }
    flunk 'Quotation_request_supply failed to build' unless quotation_request.quotation_request_supplies.build(default_attributes.merge(attributes))
    flunk 'Quotation_request_supply wasn\'t added successfully' unless quotation_request.quotation_request_supplies.size == initial_size + 1
    flunk 'Quotation_request_supply is not valid' unless quotation_request.quotation_request_supplies.last.valid?
    quotation_request.quotation_request_supplies.last
  end
  
  def build_free_quotation_request_supply(quotation_request, attributes = {})
    initial_size = quotation_request.quotation_request_supplies.size
    default_attributes = {:quantity => 1000,
                          :position => ( quotation_request.quotation_request_supplies.last && quotation_request.quotation_request_supplies.last.position.to_i + 1 ) || 0,
                          :designation => supplies("first_commodity").name,
                          :supplier_reference => SupplierSupply.first("supplier_id = ? and supply_id = ?", quotation_request.supplier_id, supplies("first_commodity").id ).supplier_reference,
                          :supplier_designation => SupplierSupply.first("supplier_id = ? and supply_id = ?", quotation_request.supplier_id, supplies("first_commodity").id ).supplier_designation }
    flunk 'Quotation_request_supply failed to build' unless quotation_request.quotation_request_supplies.build(default_attributes.merge(attributes))
    flunk 'Quotation_request_supply wasn\'t added successfully' unless quotation_request.quotation_request_supplies.size == initial_size + 1
    flunk 'Quotation_request_supply is not valid' unless quotation_request.quotation_request_supplies.last.valid?
    quotation_request.quotation_request_supplies.last
  end
  
  def build_comment_line_for_quotation_request(quotation_request, attributes = {})
    initial_size = quotation_request.quotation_request_supplies.size
    default_attributes = {:position => ( quotation_request.quotation_request_supplies.last && quotation_request.quotation_request_supplies.last.position.to_i + 1 ) || 0,
                          :comment_line => true,
                          :name => "Comment line",
                          :description => "This is a comment line for tests" }
    flunk 'Quotation_request_supply failed to build' unless quotation_request.quotation_request_supplies.build(default_attributes.merge(attributes))
    flunk 'Quotation_request_supply wasn\'t added successfully' unless quotation_request.quotation_request_supplies.size == initial_size + 1
    flunk 'Quotation_request_supply is not valid' unless quotation_request.quotation_request_supplies.last.valid?
    quotation_request.quotation_request_supplies.last
  end

# *************************     quotation         ****************************************

  def make_quotation_valid(quotation)
    quotation.creator_id = users("admin_user").id
    quotation.build_quotation_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "quotation_document.gif")))
    if quotation.quotation_request
      quotation.quotation_supplies.each do |qs|
        qs.taxes = 9.5
        qs.unit_price = 100
        qs.supplier_designation = quotation.quotation_request.quotation_request_supplies.detect{ |qr| qr.supply_id == qs.supply_id}.supplier_designation || quotation.quotation_request.quotation_request_supplies.detect{ |qr| qr.supply_id == qs.supply_id}.designation
    end
    else
      build_quotation_supply_for(quotation) unless quotation.quotation_supplies.any?
    end
    
    flunk 'Quotation is invalid' unless quotation.valid?
    quotation
  end

  def sign_quotation(quotation)
    quotation.signed_on = Date.today
    flunk 'Failed to sign the quotation' unless quotation.sign
    quotation
  end

  def create_signed_quotation_from(quotation_request)
    quotation = quotation_request.build_prefilled_quotation
    
    quotation.build_quotation_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "quotation_document.gif")))
    quotation.signed_on = Date.today
    
    make_quotation_valid(quotation)
    flunk 'Failed to sign the quotation' unless quotation.sign
    quotation
  end
  
  def create_drafted_quotation
    quotation = Quotation.new
    
    quotation.creator_id = users("admin_user").id
    quotation.supplier_id = thirds("first_supplier").id
    
    quotation.build_quotation_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "quotation_document.gif")))
    build_quotation_supply_for(quotation)
    quotation.save!
    quotation
  end
  
  def create_signed_quotation
    quotation = Quotation.new
    
    quotation.creator_id = users("admin_user").id
    quotation.supplier_id = thirds("first_supplier").id
    quotation.build_quotation_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "quotation_document.gif")))
    build_quotation_supply_for(quotation)
    quotation.signed_on = Date.today
    
    flunk 'Failed to sign the quotation directly' unless quotation.sign
    quotation
  end
  
  def create_sent_quotation
    quotation = create_signed_quotation
    quotation.sent_on = Date.today
    flunk 'Failed to sent the quotation' unless quotation.send_to_supplier
    quotation
  end
  
  def create_cancelled_quotation
    quotation = create_drafted_quotation
    quotation.cancellation_comment = "Cancelled for tests"
    quotation.canceller_id = users("admin_user").id
    flunk 'Failed to cancel the quotation' unless quotation.cancel
    quotation
  end
  
  def prepare_quotation_for_quotation_supply_test
    quotation = Quotation.new
    
    quotation.creator_id = users("admin_user").id
    quotation.supplier_id = thirds("first_supplier").id
    
    quotation.build_quotation_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "quotation_document.gif")))
    quotation
  end
  
# *************************   quotation_supplies  ****************************************
  
  def build_quotation_supply_for(quotation, attributes = {})
    default_attributes = {:supply_id => supplies("first_commodity").id,
                          :quantity => 1000,
                          :taxes => 20,
                          :unit_price => 15,
                          :prizegiving => 0,
                          :designation => supplies("first_commodity").designation,
                          :supplier_reference => SupplierSupply.find_by_supplier_id_and_supply_id(quotation.supplier_id, supplies("first_commodity").id).supplier_reference ,
                          :supplier_designation => SupplierSupply.find_by_supplier_id_and_supply_id(quotation.supplier_id, supplies("first_commodity").id).supplier_designation }
    flunk "Failed to build the quotation_supply" unless quotation.quotation_supplies.build(default_attributes.merge(attributes))
    flunk "The quotation_supply is invalid" unless quotation.quotation_supplies.last.valid?
    quotation.quotation_supplies.last
  end
  
  
  
# Issues with fixtures if supply.id is not set manually but there is issues with relationships tables if we set supply.id manually and then use dynamical filling
#  def build_purchase_request_supply(attributes = {})  
#    default_attributes = {:supply_id => supplies("first_commodity").id,
#                          :expected_quantity => 400,
#                          :expected_delivery_date => Date.today + 1.week }
#    default_attributes.merge(attributes)
#  end
#  
#  def build_purchase_request_supplies_for(purchase_request, counter)
#    counter.times do |count|
#      purchase_request.purchase_request_supplies.build(build_purchase_request_supply(:supply_id => count+1, :expected_quantity => (rand(400)+ 1)))
#    end
#    flunk 'Build of purchase_request_supplies failed' unless purchase_request.purchase_request_supplies.size == counter
#    purchase_request
#  end
#  
#  
#  def create_purchase_request(parameters = {:number_of_purchase_request_supplies => 2}, attributes = {})
#    default_attributes = {:user_id => users("admin_user").id,
#                          :employee_id => employees("john_doe").id,
#                          :service_id => services("direction_general").id }
#    purchase_request = PurchaseRequest.new(default_attributes.merge(attributes))
#    purchase_request = build_purchase_request_supplies_for(purchase_request, parameters[:number_of_purchase_request_supplies])
#    purchase_request.save!
#    flunk "purchase request should be saved" if purchase_request.new_record?
#    flunk "purchase request supplies should be saved" if purchase_request.purchase_request_supplies.select(&:new_record?).any?
#    purchase_request
#  end
  
######################################################################################################################################################################
# should replace precedent methods
  
  def create_purchase_request(args = {})
    args[:attributes] = { :user_id     => users("admin_user").id,
                          :employee_id => employees("john_doe").id,
                          :service_id  => services("direction_general").id }.merge(args[:attributes] || {})
    
    purchase_request = PurchaseRequest.new(args[:attributes])
    
    build_purchase_request_supplies_for(purchase_request, args[:purchase_request_supplies])
    purchase_request.save!
    
    flunk "purchase_request should be saved" if purchase_request.new_record?
    flunk "purchase_request_supplies should be saved" if purchase_request.purchase_request_supplies.detect(&:new_record?)
    
    purchase_request
  end
  
  def build_purchase_request_supplies_for(purchase_request, purchase_request_supplies = [] )
    if !purchase_request_supplies || purchase_request_supplies.empty?
      purchase_request_supplies = [ { :supply_id               => supplies("first_commodity").id,
                                      :expected_quantity       => 30,
                                      :expected_delivery_date  => Date.today + 1.week,
                                      :purchase_priority_id    => purchase_priorities("first_purchase_priority").id },
                                    { :supply_id               => supplies("second_commodity").id,
                                      :expected_quantity       => 30,
                                      :expected_delivery_date  => Date.today + 1.week,
                                      :purchase_priority_id    => purchase_priorities("second_purchase_priority").id } ]
    end
    
    purchase_request_supplies.each do |prs|
      purchase_request.purchase_request_supplies.build(prs)
    end
    
    flunk "purchase_request don't contain the good number of supplies" unless purchase_request.purchase_request_supplies.size == purchase_request_supplies.size
    
    purchase_request.purchase_request_supplies
  end
  
  def create_cancelled_purchase_request
    purchase_request = create_purchase_request
    purchase_request.cancelled_by_id = users("admin_user")
    purchase_request.cancelled_comment = "cancelled comment"
    purchase_request.cancel
    flunk 'Purchase_request cancellation failed' unless purchase_request.cancelled?
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
    second_purchase_order =  create_confirmed_purchase_order  
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
        flunk 'request_order_supply failed to save when creating associated purchase_request with already existing purchase_order' unless request_order_supply.save!
        counter += 1
      end
    end
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
    flunk 'build of purchase_order_supply failed' unless purchase_order.purchase_order_supplies.size == (pos_size + 1)
  end
  
  def fill_ids_with_identical_supply_ids(quotation_request, purchase_request)
    purchase_request_supplies = purchase_request.purchase_request_supplies
    quotation_request.quotation_request_supplies.each do |qrs| 
      qrs.purchase_request_supplies_ids = ""
      purchase_request_supplies.each do |prs|
        if prs.supply_id == qrs.supply_id
          qrs.purchase_request_supplies_ids += prs.id.to_s + "\;"
          purchase_request_supplies.reject{ |purchase_request_supply| purchase_request_supply == prs }
        end
      end
    end
    quotation_request.save!
  end
  
  def fill_ids_with_identical_supply_ids_for_deselection(quotation_request, purchase_request)
    purchase_request_supplies = purchase_request.purchase_request_supplies
    quotation_request.quotation_request_supplies.each do |qrs| 
      qrs.purchase_request_supplies_deselected_ids = ""
      purchase_request_supplies.each do |prs|
        if prs.supply_id == qrs.supply_id
          qrs.purchase_request_supplies_deselected_ids += prs.id.to_s + "\;"
          purchase_request_supplies.reject{ |purchase_request_supply| purchase_request_supply == prs }
        end
      end
    end
    quotation_request.save!
  end
  
  def fill_associated_pos_with_prs_ids_which_have_the_same_supply_id(purchase_order, purchase_request)
    purchase_request_supplies = purchase_request.purchase_request_supplies
    purchase_order.purchase_order_supplies.each do |pos|
      pos.purchase_request_supplies_ids = ""
      purchase_request_supplies.each do |prs|
        if prs.supply_id == pos.supply_id
          pos.purchase_request_supplies_ids += prs.id.to_s + "\;"
          purchase_request_supplies.reject{ |purchase_request_supply| purchase_request_supply == prs }
        end
      end
    end
    purchase_order.save!
  end
  
  def fill_associated_pos_with_prs_ids_which_have_the_same_supply_id_to_deselect(purchase_order, purchase_request)
    purchase_request_supplies = purchase_request.purchase_request_supplies
    purchase_order.purchase_order_supplies.each do |pos|
      pos.purchase_request_supplies_deselected_ids = ""
      purchase_request_supplies.each do |prs|
        if prs.supply_id == pos.supply_id
          pos.purchase_request_supplies_deselected_ids += prs.id.to_s + "\;"
          purchase_request_supplies.reject{ |purchase_request_supply| purchase_request_supply == prs }
        end
      end
    end
    purchase_order.save!
  end
  
  def build_purchase_order_supply(purchase_order, attributes = {})
    default_attributes = {  :supply_id => supplies("first_commodity").id,
                            :quantity => 100,
                            :taxes => 5.5,
                            :fob_unit_price => 8,
                            :supplier_reference => attributes[:supplier_reference],
                            :supplier_designation => attributes[:supplier_designation] }
    flunk 'Purchase_order_supply failed to build' unless purchase_order.purchase_order_supplies.build(default_attributes.merge(attributes))
    flunk 'Purchase_order_supply is not valid' unless purchase_order.purchase_order_supplies.last.valid?
  end
    
  def create_purchase_order(attributes = {})
    default_attributes = {  :user_id => users(:admin_user).id,
                            :supplier_id => thirds("first_supplier").id }
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
  
  def create_confirmed_purchase_order(attributes = {})
    purchase_order = create_purchase_order(attributes)
    purchase_order.build_quotation_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "quotation_document.gif")))
    build_purchase_order_supply( purchase_order, {:supply_id => supplies("second_commodity").id,
                                                  :quantity => 300,
                                                  :taxes => 5,
                                                  :supplier_reference => "C.02012010",
                                                  :supplier_designation => "Third Purchase Order Supply" } )
    purchase_order.save!
    flunk 'Confirmation failed' unless purchase_order.confirm
    flunk "Number of purchase_order_supplies is incorrect (#{purchase_order.purchase_order_supplies.size})" if purchase_order.purchase_order_supplies.size != 3
    purchase_order_supply = purchase_order.purchase_order_supplies(true).last
    purchase_order_supply.cancelled_by_id = users("admin_user").id
    purchase_order_supply.cancelled_comment = "Cancelled for tests"
    flunk 'Purchase_order_supply cancellation failed' unless purchase_order_supply.cancel
    purchase_order
  end
  
  def create_processing_purchase_order(attributes = {})
    purchase_order = create_confirmed_purchase_order(attributes)
    purchase_order.purchase_deliveries.build(  :status => PurchaseDelivery::STATUS_PROCESSING_BY_SUPPLIER,
                                    :ship_conveyance => "ship",
                                    :previsional_delivery_date => (Date.today + 10),
                                    :processing_by_supplier_since => Date.today)
    purchase_order.purchase_deliveries.first.purchase_delivery_items.build(:selected => "1",
                                                    :purchase_order_supply_id => purchase_order.purchase_order_supplies.first.id,
                                                    :quantity => (purchase_order.purchase_order_supplies.first.quantity) )
    purchase_order.save!
    purchase_order.reload
  end
  
  def prepare_purchase_order_to_be_completed(purchase_order)
    purchase_order.purchase_deliveries.build(  :previsional_delivery_date => (Date.today),
                                    :received_on => (Date.today) )
    purchase_order.purchase_deliveries.first.build_delivery_document( :purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "delivery_document.gif")) )
    purchase_order.purchase_deliveries.first.purchase_delivery_items.build(  :selected => "1",
                                                      :purchase_order_supply_id => purchase_order.purchase_order_supplies.first.id,
                                                      :quantity => (purchase_order.purchase_order_supplies.first.quantity) )
    purchase_order.purchase_deliveries.first.purchase_delivery_items.build(  :selected => "1",
                                                      :purchase_order_supply_id => purchase_order.purchase_order_supplies[1].id,
                                                      :quantity => (purchase_order.purchase_order_supplies[1].quantity) )
    flunk '"purchase_delivery failed" to be received when preparing purchase_order to be completed' unless purchase_order.purchase_deliveries.first.receive
    flunk 'purchase_order failed to save when preparing purchase_order to be completed' unless purchase_order.save!
    purchase_order.reload
    purchase_order.build_invoice_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "invoice_document.gif")))
    purchase_order
  end
  
  def build_purchase_delivery_item_for(purchase_delivery, purchase_order = nil)
    purchase_order = create_confirmed_purchase_order unless purchase_order
    purchase_delivery.status = PurchaseDelivery::STATUS_PROCESSING_BY_SUPPLIER
    purchase_delivery.processing_by_supplier_since = Date.today
    purchase_delivery.purchase_delivery_items.build({ :purchase_order_supply_id => purchase_order.purchase_order_supplies.first.id,
                                :quantity => purchase_order.purchase_order_supplies.first.quantity,
                                :selected => "1"})
    purchase_delivery
  end
  
  def put_received_status_for(purchase_delivery)
    purchase_delivery.received_on = Date.today
    purchase_delivery.build_delivery_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "delivery_document.gif")))
    flunk "purchase_delivery should be put in received status" unless purchase_delivery.receive
    purchase_delivery
  end
  
  
  def create_valid_purchase_delivery
    purchase_delivery = PurchaseDelivery.new
    purchase_delivery = build_purchase_delivery_item_for(purchase_delivery, nil)
    flunk "purchase_delivery should be saved" unless purchase_delivery.save!
    purchase_delivery
  end
  
  def processing_by_supplier_purchase_delivery
    purchase_delivery = PurchaseDelivery.new
    purchase_delivery = build_purchase_delivery_item_for(purchase_delivery, nil)
    flunk "purchase_delivery should in processing_by_supplier_purchase_delivery status" unless purchase_delivery.process_by_supplier
    flunk "purchase_delivery should in processing_by_supplier_purchase_delivery status" unless purchase_delivery.processing_by_supplier?
    purchase_delivery
  end
  
  def shipped_purchase_delivery
    purchase_delivery = create_valid_purchase_delivery
    purchase_delivery.shipped_on = Date.today
    purchase_delivery.ship_conveyance = "par avion"
    flunk "purchase_delivery should in shipped status" unless purchase_delivery.ship
    flunk "purchase_delivery should in shipped status" unless purchase_delivery.shipped?
    purchase_delivery
  end
  
  def received_by_forwarder_purchase_delivery
    purchase_delivery = create_valid_purchase_delivery
    purchase_delivery.received_by_forwarder_on = Date.today
    flunk "purchase_delivery should be in received_by_forwarder status" unless purchase_delivery.receive_by_forwarder
    flunk "purchase_delivery should be in received_by_forwarder status" unless purchase_delivery.received_by_forwarder?
    purchase_delivery
  end  
  
  def received_purchase_delivery
    purchase_delivery = create_valid_purchase_delivery
    purchase_delivery.received_on = Date.today
    purchase_delivery.delivery_document_attributes = [{:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "delivery_document.gif"))}]
    flunk "purchase_delivery should in received status" unless purchase_delivery.receive
    flunk "purchase_delivery should in received status" unless purchase_delivery.received?
    flunk 'purchase_delivery should have delivery_document' unless purchase_delivery.delivery_document
    purchase_delivery
  end
  
  def cancelled_purchase_delivery
    purchase_delivery = create_valid_purchase_delivery
    purchase_delivery.cancelled_comment = "cancelled purchase_delivery"
    flunk "purchase_delivery should be cancelled" unless purchase_delivery.cancel
    flunk "purchase_delivery should be cancelled" unless purchase_delivery.cancelled?
    purchase_delivery
  end
  
  def create_purchase_order_supply_reported_for(purchase_delivery_item)
    purchase_delivery_item.must_be_reshipped = "1"
    purchase_delivery_item.issues_comment = "purchase_order_supply reported"
    purchase_delivery_item.issues_quantity = purchase_delivery_item.quantity
    flunk "purchase_delivery_item should be reported" unless purchase_delivery_item.report
    flunk "issue_purchase_order_supply should be create" if purchase_delivery_item.issue_purchase_order_supply.new_record?
    purchase_delivery_item.issue_purchase_order_supply
  end
end
