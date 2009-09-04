require 'test/test_helper'

class LeaveTest < ActiveSupport::TestCase
  
  def setup
    @good_leave = Leave.new(:start_date     => "2009-10-12".to_date,
                            :end_date       => "2009-10-18".to_date,
                            :duration       => 7.0,
                            :employee_id    => Employee.first.id,
                            :leave_type_id  => LeaveType.first.id)
    flunk "good_leave is not valid #{@good_leave.errors.inspect}" unless @good_leave.save
    
    ConfigurationManager.admin_society_identity_configuration_leave_year_start_date = (Date.today - 11.month).strftime("%m/%d")
    
    @leave = Leave.new
    @leave.valid?
  end
  
  def teardown
    @good_leave = nil
    @leave = nil
  end
  
  def test_persistence_of_cancelled
    assert !@good_leave.errors.invalid?(:cancelled), "cancelled should be valid because is not modified"
    
    @good_leave.cancelled = true
    @good_leave.valid?
    assert @good_leave.errors.invalid?(:cancelled), "cancelled should NOT be valid because is it can't be modified while a normal edit"
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
    assert @leave.errors.invalid?(:leave_type), "leave_type_id should NOT be valid because employee_id is wrong"
    
    assert !@good_leave.errors.invalid?(:leave_type_id), "leave_type_id should be valid"
    assert !@good_leave.errors.invalid?(:leave_type), "leave_type_id should be valid"  
  end
  
  def test_presence_of_employee
    assert @leave.errors.invalid?(:employee_id), "employee_id should NOT be valid because it's nil"
    
    @leave.employee_id = 0
    @leave.valid?
    assert !@leave.errors.invalid?(:employee_id), "employee_id should be valid"
    assert @leave.errors.invalid?(:employee), "employee_id should NOT be valid because employee_id is wrong"
    
    assert !@good_leave.errors.invalid?(:employee_id), "employee_id should be valid"
    assert !@good_leave.errors.invalid?(:employee), "employee_id should be valid"  
  end
  
  def test_not_cancelled_at_creation
    assert !@leave.errors.invalid?(:cancelled), "cancelled should be valid because nil is allowed"
    
    @leave.cancelled = true
    @leave.valid?
    assert @leave.errors.invalid?(:cancelled), "cancelled should be NOT valid because it's cancelled is true for a new record"   
    @leave.cancelled = false
    @leave.valid?
    assert !@leave.errors.invalid?(:cancelled), "cancelled should be valid"
  end

  def test_date_is_correct
    assert !@good_leave.errors.invalid?(:start_date), "start_date should be valid"
    assert !@good_leave.errors.invalid?(:end_date), "end_date should be valid"
    
    @leave.start_date = @good_leave.end_date
    @leave.end_date = @good_leave.start_date
    @leave.valid?
    assert @leave.errors.invalid?(:start_date), "start_date should NOT be valid"
    assert @leave.errors.invalid?(:end_date), "end_date should NOT be valid"
    
    @leave.end_date = @leave.start_date
    @leave.start_half = @leave.end_half = true
    @leave.valid?
    assert @leave.errors.invalid?(:start_half), "date should NOT be valid"
    assert @leave.errors.invalid?(:end_half), "date should NOT be valid"   
  end
  
  def test_not_overlay_with_other_leave
    @leave = Leave.new(@good_leave.attributes)
    @leave.start_date = @good_leave.end_date + 4.day
    @leave.end_date = @leave.start_date + 4.day
    @leave.valid?
    assert !@leave.errors.invalid?(:start_date), "start_date should be valid because leave period don't overlay good_leave one"
    assert !@leave.errors.invalid?(:end_date), "start_date should be valid because leave period don't overlay good_leave one"
    
    # start date si in another leave period
    @leave.start_date = @good_leave.end_date - 2.day
    @leave.valid?
    assert @leave.errors.invalid?(:start_date), "start_date should NOT be valid because leave period overlay good_leave one"
    
    # start date is the same day that the end date of another leave, but not the same day half
    @leave.start_date = @good_leave.end_date
    @leave.start_half = @good_leave.end_half = true
    @leave.valid?
    assert !@leave.errors.invalid?(:start_date), "start_date should be valid because leave period don't overlay good_leave one"
    
    # end date is in another leave period
    @leave.start_date = @good_leave.start_date - 2.day
    @leave.end_date = @leave.start_date + 4.day
    @leave.valid?
    assert @leave.errors.invalid?(:end_date), "start_date should NOT be valid because leave period overlay good_leave one"
    
    # end date is the same day that the start date of another leave, but not the same day half
    @leave.end_date = @good_leave.start_date
    @leave.end_half = @good_leave.start_half = true
    @leave.valid?
    assert !@leave.errors.invalid?(:end_date), "end_date should be valid because leave period don't overlay good_leave one"
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
    # bad date (periode)
    @leave = @good_leave
    @leave.end_date -= 20.days
    assert_equal 0, @leave.total_estimate_duration, "total_estimate_duration should be 0 because end_date < start_date,  workable_days: #{workable_days.inspect}"
    # one day
    @leave.end_date = @leave.start_date
    assert_equal 1, @leave.total_estimate_duration, "total_estimate_duration Should be 1 because end_date == start_date,  workable_days: #{workable_days.inspect}"
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
    mess = " #{@leave.start_date} to #{@leave.end_date},start_half: #{@leave.start_half},end_half: #{@leave.end_half}"
    wanted_duration = 2
    assert_equal wanted_duration, @leave.total_estimate_duration, "total_estimate_duration should be #{wanted_duration} :#{mess}"
    
    @leave.end_half = true
    wanted_duration = 1.5
    assert_equal wanted_duration, @leave.total_estimate_duration, "total_estimate_duration should be #{wanted_duration} :#{mess}"
    
    @leave.start_half = true  
    wanted_duration = 1
    assert_equal wanted_duration, @leave.total_estimate_duration, "total_estimate_duration should be #{wanted_duration} :#{mess}"
  end
  
  def test_total_estimate_duration_with_legal_holidays
    ConfigurationManager.admin_society_identity_configuration_workable_days = "0123456".split("")
    ConfigurationManager.admin_society_identity_configuration_legal_holidays = ["10/14","10/17"]
    assert_equal 5, @good_leave.total_estimate_duration, "total_estimate_duration should be 5 because there's 2 legal_holidays within the leave period #{ConfigurationManager.admin_society_identity_configuration_legal_holidays.inspect}"
  end
  
  def test_calendar_duration
    # when start_date == nil and end_date == nil
    assert_equal 0, @leave.calendar_duration, "calendar_duration should be equal to 0"
    
    # when start_date or end_date == nil
    @leave.start_date = Date.today
    assert_equal 0, @leave.calendar_duration, "calendar_duration should be equal to 0"
    
    # when start_date == end_date
    @leave.end_date = @leave.start_date
    assert_equal 1, @leave.calendar_duration, "calendar_duration should be equal to 1"
    
    # when start_date > end_date
    @leave.end_date = Date.today - 1.day
    assert_equal 0, @leave.calendar_duration, "calendar_duration should be equal to 0"
    
    # when start_date < end_date
    @leave.end_date = Date.today + 1.day
    assert_equal 2, @leave.calendar_duration, "calendar_duration should be equal to 2"
    
    # with start_half
    @leave.start_half = true
    assert_equal 1.5, @leave.calendar_duration, "calendar_duration should be equal to 1.5"
    
    # with end_half
    @leave.end_half = true
    assert_equal 1, @leave.calendar_duration, "calendar_duration should be equal to 1"
  end
  
  def test_start_datetime
    @leave.start_date = Date.today
    @leave.start_half = true
    assert_equal Date.today.to_datetime + 12.hours, @leave.start_datetime, "start_datetime should be equal to #{Date.today.to_datetime + 12.hours} if start_half is true"
  end
  
  def test_end_datetime
    @leave.end_date = Date.today
    @leave.end_half = true
    assert_equal Date.today.to_datetime - 12.hours, @leave.end_datetime, "end_datetime should be equal to #{Date.today.to_datetime - 12.hours} if end_half is true"
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
  
  def test_persistance_of_attributes_when_leave_is_cancelled
    #TODO
  end
  
  private
    
    def total_estimate_duration_test(workable_days)
      @leave.start_date = "2009-4-13".to_date
      @leave.end_date = "2009-4-26".to_date      
      ConfigurationManager.admin_society_identity_configuration_workable_days = workable_days
      wanted_duration = workable_days.size*2
      assert_equal wanted_duration, @leave.total_estimate_duration, "total_estimate_duration Should be #{wanted_duration} : #{@leave.start_date} to #{@leave.end_date}, workable_days: #{workable_days.inspect} #{ConfigurationManager.admin_society_identity_configuration_workable_days.inspect}"
    end
end
