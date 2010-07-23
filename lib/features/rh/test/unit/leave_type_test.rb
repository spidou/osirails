require File.dirname(__FILE__) + '/../rh_test'

class LeaveTypeTest < ActiveSupport::TestCase
  def setup
    @good_leave_type = leave_types(:good_leave_type)
    @good_leave_type.valid?
    flunk "good_leave_type is not valid" unless @good_leave_type.valid?
    
    @leave_type = LeaveType.new
    @leave_type.valid?
  end
  
  def teardown
   @good_leave_type = nil
   @leave_type = nil
  end
  
  def test_presence_of_name
    assert @leave_type.errors.invalid?(:name), "name should NOT be valid because is nil"
    assert !@good_leave_type.errors.invalid?(:name), "name should be valid"
  end
  
  def test_uniqueness_of_name
    @leave_type.name = @good_leave_type.name
    @leave_type.valid?
    assert @leave_type.errors.invalid?(:name), "name should NOT be valid because is not unique"
    
    @leave_type.name = "uniq_name_not_already_used"
    @leave_type.valid?
    assert !@good_leave_type.errors.invalid?(:name), "name should be valid"
  end
end
