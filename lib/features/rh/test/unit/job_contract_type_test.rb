require File.dirname(__FILE__) + '/../rh_test'

class JobContractTypeTest < ActiveSupport::TestCase
  should_validate_presence_of :name
  
  should_allow_values_for :limited, true, false
  should_not_allow_values_for :limited, nil
  
  should_journalize :identifier_method => :name
end
