require 'test/test_helper'
require File.dirname(__FILE__) + '/leave_base_test'
require File.dirname(__FILE__) + '/leave_validations_test'

class LeaveTest < ActiveSupport::TestCase
  include LeaveBaseTest
  include LeaveValidationsTest
  
  def setup
    @employee = employees(:trish_doe)
    @leave_type = leave_types(:good_leave_type)
    
    @good_leave = Leave.new(:start_date     => Date.today.next_month.monday,
                            :end_date       => Date.today.next_month.monday + 6.days,
                            :start_half     => true,
                            :end_half       => true,
                            :duration       => 6,
                            :employee_id    => @employee.id,
                            :leave_type_id  => @leave_type.id)
    flunk "good_leave is not valid #{@good_leave.errors.inspect}" unless @good_leave.save
    
    ConfigurationManager.admin_society_identity_configuration_leave_year_start_date = (Date.today - 11.months).strftime("%m/%d")
    
    @leave = Leave.new
    @leave.valid?
    
    setup_leaves
  end
  
  def teardown
    @good_leave = nil
    @leave = nil
  end
  
  def test_persistence_of_cancelled
    assert !@good_leave.errors.invalid?(:cancelled), "cancelled should be valid because is not modified"
    
    @good_leave.cancelled = true
    @good_leave.valid?
    assert @good_leave.errors.invalid?(:cancelled), "cancelled should NOT be valid because it can't be modified while a normal edit"
  end
  
  def test_persistence_of_employee_id
    assert !@good_leave.errors.invalid?(:employee_id), "employee_id should be valid because is not modified"
    
    @good_leave.employee_id = employees(:james_doe).id
    @good_leave.valid?
    assert @good_leave.errors.invalid?(:employee_id), "employee_id should NOT be valid because is modified"
  end
  
  def test_presence_of_start_date
    assert @leave.errors.invalid?(:start_date), "start_date should NOT be valid because it's nil"
    assert !@good_leave.errors.invalid?(:start_date), "start_date should be valid"
  end
  
  def test_presence_of_end_date
    assert @leave.errors.invalid?(:end_date), "end_date should NOT be valid because it's nil"
    assert !@good_leave.errors.invalid?(:end_date), "end_date should be valid"
  end
  
  def test_numericality_of_duration
    assert @leave.errors.invalid?(:duration), "duration should NOT be valid because it's nil"
    
    @leave.duration = "string"
    @leave.valid?
    assert @leave.errors.invalid?(:duration), "duration should NOT be valid because it's not a numerical value"
    assert !@good_leave.errors.invalid?(:duration), "duration should be valid"
  end
  
  def test_presence_of_leave_type
    assert @leave.errors.invalid?(:leave_type_id), "leave_type_id should NOT be valid because it's nil"
    
    @leave.leave_type_id = 0
    @leave.valid?
    assert !@leave.errors.invalid?(:leave_type_id), "leave_type_id should be valid"
    assert @leave.errors.invalid?(:leave_type), "leave_type should NOT be valid because employee_id is wrong"
    
    assert !@good_leave.errors.invalid?(:leave_type_id), "leave_type_id should be valid"
    assert !@good_leave.errors.invalid?(:leave_type), "leave_type should be valid"  
  end
  
  def test_presence_of_employee
    assert @leave.errors.invalid?(:employee_id), "employee_id should NOT be valid because it's nil"
    
    @leave.employee_id = 0
    @leave.valid?
    assert !@leave.errors.invalid?(:employee_id), "employee_id should be valid"
    assert @leave.errors.invalid?(:employee), "employee should NOT be valid because employee_id is wrong"
    
    assert !@good_leave.errors.invalid?(:employee_id), "employee_id should be valid"
    assert !@good_leave.errors.invalid?(:employee), "employee should be valid"  
  end
  
  def test_not_cancelled_at_creation
    assert !@leave.errors.invalid?(:cancelled), "cancelled should be valid because nil is allowed"
    
    @leave.cancelled = true
    @leave.valid?
    assert @leave.errors.invalid?(:cancelled), "cancelled should NOT be valid because cancelled is true for a new record"   
    @leave.cancelled = false
    @leave.valid?
    assert !@leave.errors.invalid?(:cancelled), "cancelled should be valid"
  end
  
  def test_total_estimate_duration_without_in_parameters
    ConfigurationManager.admin_society_identity_configuration_workable_days = []
    assert_equal 0, @good_leave.total_estimate_duration, "total_estimate_duration should be 0 because there's no workable days"
    @leave = Leave.new
    assert_equal 0, @leave.total_estimate_duration, "total_estimate_duration should be 0 because there's no workable days and, start_date or end_date is nil"
  end
  
  def test_total_estimate_duration_with_in_parameters
    # the keys represent the workable_days arrays and their size*2(size=>days/week, 2=>weeks) represent the wanted duration
    # to be calculated by the tested method.
    # this duration are based onto 2 weeks starting on "2009-10-12" and ending on "2009-10-25"
  
    workable_days = ConfigurationManager.admin_society_identity_configuration_workable_days = "123456".split("")
    # when start_date > end_date
    @leave.start_date = @good_leave.start_date
    @leave.end_date = @leave.start_date - 2.days
    assert_equal 0, @leave.total_estimate_duration, "total_estimate_duration should be 0 because end_date < start_date, workable_days: #{workable_days.inspect}"
    
    # when start_date == end_date
    @leave.end_date = @leave.start_date
    assert_equal 1, @leave.total_estimate_duration, "total_estimate_duration should be 1 because end_date == start_date, workable_days: #{workable_days.inspect}"
    
    # when start_date < end_date
    @leave.end_date = @leave.start_date + 1.days
    assert_equal 2, @leave.total_estimate_duration, "total_estimate_duration should be 2 because start_date < end_date, workable_days: #{workable_days.inspect}"
  end
       
  def test_total_estimate_duration_with_3_successives_workable_days
    total_estimate_duration_test("012".split(""))
  end
  
  def test_total_estimate_duration_with_5_successives_workable_days
    total_estimate_duration_test("13456".split(""))
  end
  
  def test_total_estimate_duration_with_1_workable_day
    total_estimate_duration_test("1".split(""))
  end
  
  def test_total_estimate_duration_with_3_not_successives_workable_days
    total_estimate_duration_test("146".split(""))
  end
  
  def test_total_estimate_duration_with_all_the_week_days_workable
    total_estimate_duration_test("0123456".split(""))
  end
  
  def test_total_estimate_duration_with_2_workable_days_not_close
    total_estimate_duration_test("15".split(""))
  end
  
  def test_total_estimate_duration_with_half_days
    @leave.start_date = "2009-4-13".to_date
    @leave.end_date = "2009-4-14".to_date
    ConfigurationManager.admin_society_identity_configuration_workable_days = "0123456".split("")
    mess = " #{@leave.start_date} to #{@leave.end_date}, start_half: #{@leave.start_half}, end_half: #{@leave.end_half}"
    wanted_duration = 2
    assert_equal wanted_duration, @leave.total_estimate_duration, "total_estimate_duration should be #{wanted_duration} :#{mess}"
    
    @leave.end_half = true
    wanted_duration = 1.5
    assert_equal wanted_duration, @leave.total_estimate_duration, "total_estimate_duration should be #{wanted_duration} :#{mess}"
    
    @leave.start_half = true  
    wanted_duration = 1
    assert_equal wanted_duration, @leave.total_estimate_duration, "total_estimate_duration should be #{wanted_duration} :#{mess}"
  end
  
  def test_total_estimate_duration_without_legal_holidays
    ConfigurationManager.admin_society_identity_configuration_workable_days = "0123456".split("")
    ConfigurationManager.admin_society_identity_configuration_legal_holidays = []
    
    assert_equal 6, @good_leave.total_estimate_duration, "total_estimate_duration should be equal to 6 without legal_holidays"
  end
  
  def test_total_estimate_duration_with_legal_holidays
    first_holiday  = (@good_leave.start_date + 1.day).strftime("%m/%d")
    second_holiday = (@good_leave.start_date + 2.days).strftime("%m/%d")
    ConfigurationManager.admin_society_identity_configuration_workable_days = "0123456".split("")
    ConfigurationManager.admin_society_identity_configuration_legal_holidays = [first_holiday, second_holiday]
    
    assert_equal 4, @good_leave.total_estimate_duration, "total_estimate_duration should be 4 because there's 2 legal_holidays within the leave period #{ConfigurationManager.admin_society_identity_configuration_legal_holidays.inspect}"
  end
  
  def test_cancel
    assert_equal true, @good_leave.cancel, "@good_leave should be valid "
    
    @good_leave.reload.start_date = nil
    assert_equal false, @good_leave.cancel, "@good_leave should NOT be valid because of a validation error" 
  end
  
  def test_can_be_edited
    flunk "@good_leave should NOT be cancelled to perform the following" if @good_leave.cancelled
    
    assert @good_leave.can_be_edited?, "@good_leave should be editable"
    
    flunk "@good_leave shoud be cancelled" unless @good_leave.cancel
    
    assert !@good_leave.can_be_edited?, "@good_leave should NOT be editable"
  end
  
  def test_can_be_cancelled
    flunk "@good_leave should NOT be cancelled to perform the following" if @good_leave.cancelled
    
    assert @good_leave.can_be_cancelled?, "@good_leave should be cancellable"
    
    flunk "@good_leave shoud be cancelled" unless @good_leave.cancel
    
    assert !@good_leave.can_be_cancelled?, "@good_leave should NOT be cancellable"
  end
  
  def test_persistence_of_attributes
    hash = {:start_date    => @good_leave.start_date + 1,
            :end_date      => @good_leave.end_date + 2,
            :start_half    => !@good_leave.start_half,
            :end_half      => !@good_leave.end_half,
            :leave_type_id => leave_types(:leave_type_to_test_edit).id,
            :duration      => @good_leave.duration + 1}
            
    # when leave IS NOT cancelled
    hash.each do |attribute, new_value|
      flunk "new value of '#{attribute}' should NOT be equal to '#{new_value}' to perform the following" if @good_leave.send(attribute) == new_value
      
      assert !@good_leave.errors.invalid?(attribute), "#{attribute.to_s} should be valid because it's not modified"
      
      @good_leave.send("#{attribute.to_s}=", new_value)
      @good_leave.valid?
      assert !@good_leave.errors.invalid?(attribute), "#{attribute.to_s} should be valid because a leave can be modified if it's not cancelled"
    end
    
    # when leave IS cancelled
    flunk "@good_leave should be cancelled to perform the following" unless @good_leave.reload.cancel
    hash.each do |attribute, new_value|
      flunk "new value of '#{attribute}' should NOT be equal to '#{new_value}' to perform the following" if @good_leave.send(attribute) == new_value
      
      assert !@good_leave.errors.invalid?(attribute), "#{attribute.to_s} should be valid because it's not modified"
      
      @good_leave.send("#{attribute.to_s}=", new_value)
      @good_leave.valid?
      assert @good_leave.errors.invalid?(attribute), "#{attribute.to_s} should NOT be valid because a leave can't modified if it's cancelled"
    end
  end
  
  private
    
    def total_estimate_duration_test(workable_days)
      @leave.start_date = "2009-4-13".to_date
      @leave.end_date = "2009-4-26".to_date      
      ConfigurationManager.admin_society_identity_configuration_workable_days = workable_days
      wanted_duration = workable_days.size*2
      assert_equal wanted_duration, @leave.total_estimate_duration, "total_estimate_duration should be #{wanted_duration} : #{@leave.start_date} to #{@leave.end_date}, workable_days: #{workable_days.inspect} #{ConfigurationManager.admin_society_identity_configuration_workable_days.inspect}"
    end
end
