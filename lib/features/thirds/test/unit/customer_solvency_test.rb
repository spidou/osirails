require File.dirname(__FILE__) + '/../thirds_test'

class CustomerSolvencyTest < ActiveSupport::TestCase
  should_belong_to :granted_payment_time
  
  should_journalize :identifier_method => :name
end
