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
  
end
