require File.dirname(__FILE__) + '/../thirds_test'

class CustomerGradeTest < ActiveSupport::TestCase
  should_belong_to :granted_payment_method
  
  should_journalize :identifier_method => :name
end
