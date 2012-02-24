require File.dirname(__FILE__) + '/../rh_test'

class SalaryTest < ActiveSupport::TestCase
  should_belong_to :job_contract
  should_validate_numericality_of :gross_amount, :net_amount
  should_validate_presence_of :date
end
