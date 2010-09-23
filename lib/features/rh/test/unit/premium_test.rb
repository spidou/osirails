require File.dirname(__FILE__) + '/../rh_test'

class PremiumTest < ActiveSupport::TestCase
  #TODO test has_permissions :as_business_object
  
  should_belong_to :employee 
  
  should_validate_numericality_of :amount
  should_validate_presence_of :date, :remark
end
