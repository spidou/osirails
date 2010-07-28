require 'test/test_helper'
require File.dirname(__FILE__) + '/../purchases_test'

class RequestOrderSupplyTest < ActiveSupport::TestCase
  
  should_belong_to :purchase_order_supply, :purchase_request_supply
  should_validate_presence_of :purchase_request_supply_id
  
end
