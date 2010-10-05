require File.dirname(__FILE__) + '/../purchases_test'

class QuotationPurchaseRequestSupplyTest < ActiveSupport::TestCase
  should_belong_to :quotation_supply, :purchase_request_supply
  should_validate_presence_of :purchase_request_supply, :with_foreign_key => :default
end
