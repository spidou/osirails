require File.dirname(__FILE__) + '/../purchases_test'

class ParcelTest < ActiveSupport::TestCase
  
  should_belong_to :purchase_delivery
  should_validate_presence_of :reference
  
end
