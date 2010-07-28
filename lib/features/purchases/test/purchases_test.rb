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
  
  def create_confirmed_purchase_order(user_id, supplier_id)
    purchase_order = create_valid_draft_purchase_order(user_id, supplier_id)
    purchase_document_build(purchase_order, :purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "quotation_document.gif")))
    flunk "Confirmation failed" unless purchase_order.confirm!
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
end
