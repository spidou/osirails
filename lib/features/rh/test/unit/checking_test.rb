require File.dirname(__FILE__) + '/../rh_test'

class CheckingTest < ActiveSupport::TestCase
  def setup
    @good_checking = checkings(:good_checking)
    flunk "good cheking is not valid #{@good_checking.errors.inspect}" unless @good_checking.valid?
    flunk "@good_checking.date should be in the same week than today" unless @good_checking.date.cweek == Date.today.cweek
    
    @checking = Checking.new
    @checking.valid?
  end
  
  def teardown
    @good_checking = nil
    @checking = nil
  end
  
  def test_persistence_of_user_id
    assert !@good_checking.errors.invalid?(:user_id), "user_id should be valid because is not modified"
    
    @good_checking.user_id = 0
    @good_checking.valid?
    assert @good_checking.errors.invalid?(:user_id), "user_id should NOT be valid because is modified"
  end
  
  def test_persistence_of_employee_id
    assert !@good_checking.errors.invalid?(:employee_id), "employee_id should be valid because is not modified"
    
    @good_checking.employee_id = 0
    @good_checking.valid?
    assert @good_checking.errors.invalid?(:employee_id), "employee_id should NOT be valid because is modified"
  end
  
  def test_persistence_of_date
    assert !@good_checking.errors.invalid?(:date), "date should be valid because is not modified"
    
    @good_checking.date -= 1.day
    @good_checking.valid?
    assert @good_checking.errors.invalid?(:date), "date should NOT be valid because is modified"
  end
    
  def test_persistence_of_cancelled
    assert !@good_checking.errors.invalid?(:cancelled), "cancelled should be valid because is not modified"
    
    @good_checking.cancelled = true
    @good_checking.valid?
    assert @good_checking.errors.invalid?(:cancelled), "cancelled should NOT be valid because is it can't be modified while a normal edit"
  end
  
  # overtime
  
  def test_numericality_of_overtime_hours
    @good_checking.overtime_hours = nil
    @good_checking.valid?
    assert !@good_checking.errors.invalid?(:overtime_hours), "overtime_hours should be valid because nil is allowed"
    
    @checking.overtime_hours = "string"
    @checking.valid?
    assert @checking.errors.invalid?(:overtime_hours), "overtime_hours should NOT be valid because it's not a numerical value"
    assert !@good_checking.errors.invalid?(:overtime_hours), "overtime_hours should be valid"
  end
  
  def test_numericality_of_overtime_minutes
    @good_checking.overtime_minutes = nil
    @good_checking.valid?
    assert !@good_checking.errors.invalid?(:overtime_minutes), "overtime_minutes should be valid because nil is allowed"
    
    @checking.overtime_minutes = "string"
    @checking.valid?
    assert @checking.errors.invalid?(:overtime_minutes), "overtime_minutes should NOT be valid because it's not a numerical value"
    assert !@good_checking.errors.invalid?(:overtime_minutes), "overtime_minutes should be valid"
  end
  
  def test_presence_of_overtime_comment
    assert !@good_checking.errors.invalid?(:overtime_comment), "overtime_comment should be valid"
    
    @good_checking.overtime_comment = nil
    @good_checking.overtime_hours = 2
    @good_checking.valid?
    assert @good_checking.errors.invalid?(:overtime_comment), "overtime_comment should NOT be valid because it's nil"
    
    @good_checking.overtime_hours = nil
    @good_checking.overtime_minutes = nil
    @good_checking.valid?
    assert !@good_checking.errors.invalid?(:overtime_comment), "overtime_comment should be valid because it's no longer mandatory"
  end
  
  # absence
  
  def test_numericality_of_absence_hours
    @good_checking.absence_hours = nil
    @good_checking.valid?
    assert !@good_checking.errors.invalid?(:absence_hours), "absence_hours should be valid because nil is allowed"
    
    @checking.absence_hours = "string"
    @checking.valid?
    assert @checking.errors.invalid?(:absence_hours), "absence_hours should NOT be valid because it's not a numerical value"
    assert !@good_checking.errors.invalid?(:absence_hours), "absence_hours should be valid"
  end
  
  def test_numericality_of_absence_minutes
    @good_checking.overtime_minutes = nil
    @good_checking.valid?
    assert !@good_checking.errors.invalid?(:absence_minutes), "absence_minutes should be valid because nil is allowed"
    
    @checking.absence_minutes = "string"
    @checking.valid?
    assert @checking.errors.invalid?(:absence_minutes), "absence_minutes should NOT be valid because it's not a numerical value"
    assert !@good_checking.errors.invalid?(:absence_minutes), "absence_minutes should be valid"
  end
  
  def test_presence_of_absence_comment
    assert !@good_checking.errors.invalid?(:absence_comment), "absence_comment should be valid"
    
    @good_checking.absence_comment = nil
    @good_checking.absence_hours = 2
    @good_checking.valid?
    assert @good_checking.errors.invalid?(:absence_comment), "absence_comment should NOT be valid because it's nil"
    
    @good_checking.absence_hours = nil
    @good_checking.absence_minutes = nil
    @good_checking.valid?
    assert !@good_checking.errors.invalid?(:absence_comment), "absence_comment should be valid because it's no longer mandatory"
  end

  ####
    
  def test_presence_of_date
    assert @checking.errors.invalid?(:date), "date should NOT be valid because it's nil"
    assert !@good_checking.errors.invalid?(:date), "date should be valid"
  end
  
  def test_presence_of_employee
    assert @checking.errors.invalid?(:employee_id), "employee_id should NOT be valid because it's nil"
    
    @checking.employee_id = 0
    @checking.valid?
    assert !@checking.errors.invalid?(:employee_id), "employee_id should be valid"
    assert @checking.errors.invalid?(:employee), "employee_id should NOT be valid because employee_id is wrong"
    
    assert !@good_checking.errors.invalid?(:employee_id), "employee_id should be valid"
    assert !@good_checking.errors.invalid?(:employee), "employee should be valid" 
  end
  
  def test_presence_of_user
    assert @checking.errors.invalid?(:user_id), "user_id should NOT be valid because it's nil"
    
    @checking.user_id = 0
    @checking.valid?
    assert !@checking.errors.invalid?(:user_id), "user_id should be valid"
    assert @checking.errors.invalid?(:user), "user should NOT be valid because employee_id is wrong"
    
    assert !@good_checking.errors.invalid?(:user_id), "user_id should be valid"
    assert !@good_checking.errors.invalid?(:user), "user should be invalid"
  end
    
  def test_one_checking_per_day_and_per_employee
    # not a new record
    assert !@good_checking.errors.invalid?(:date), "date should be valid"
    assert !@good_checking.errors.invalid?(:employee_id), "employee_id should be valid"
     
    # same employee and same date
    @checking.attributes = checkings(:good_checking).attributes
    @checking.valid?
    assert @checking.errors.invalid?(:date), "date should NOT be valid because the couple (date, employee_id) already exists"
    assert @checking.errors.invalid?(:employee_id), "employee_id should NOT be valid because the couple (date, employee_id) already exists"
    
    # same employee but change the date
    @checking.date -= 1.day
    @checking.valid?
    assert !@checking.errors.invalid?(:date), "date should be valid"
    assert !@checking.errors.invalid?(:employee_id), "employee_id should be valid"
    
    # same date but change the employee
    @checking.attributes = checkings(:good_checking).attributes
    @checking.employee = employees(:james_doe)
    @checking.valid?
    assert !@checking.errors.invalid?(:date), "date should be valid"
    assert !@checking.errors.invalid?(:employee_id), "employee_id should be valid"
  end
  
  def test_one_checking_per_day_and_per_employee_with_first_checking_cancelled
    @checking.attributes = @good_checking.attributes

    flunk "@good_checking should be cancelled" unless @good_checking.cancel

    @checking.valid?
    assert !@checking.errors.invalid?(:date), "date should be valid"
    assert !@checking.errors.invalid?(:employee_id), "employee_id should be valid"
  end
  
  def test_can_be_edited
    # when we are on the same week of the checking date (it's 
    assert @good_checking.can_be_edited?, "@good_checking should be editable because we are on the same week of the checking date"
    
    # when we are before the week of the checking date (it's still ok)
    @checking = Checking.new(@good_checking.attributes)
    @checking.date = Date.today.next_week
    flunk "@checking should be saved" unless @checking.save
    assert @checking.can_be_edited?, "@good_checking should be editable because we are before the week of the checking date"
    
    # when we are after the week of the checking date (it's too late)
    @checking = Checking.new(@good_checking.attributes)
    @checking.date = Date.today.last_week
    flunk "@checking should be saved" unless @checking.save
    assert !@checking.can_be_edited?, "@good_checking should NOT be editable because we are after the week of the checking date"
  end
  
  def test_update
    #TODO
  end
  
  def test_can_be_overrided
    # when we are on the same week of the checking date (it's NOT ok)
    assert !@good_checking.can_be_overrided?, "@good_checking should NOT be overridable because we are on the same week of the checking date"
    
    # when we are before the week of the checking date (it's still NOT ok)
    @checking = Checking.new(@good_checking.attributes)
    @checking.date = Date.today.next_week
    flunk "@checking should be saved" unless @checking.save
    assert !@checking.can_be_overrided?, "@good_checking should NOT be overridable because we are before the week of the checking date"
    
    # when we are after the week of the checking date (it's ok)
    @checking = Checking.new(@good_checking.attributes)
    @checking.date = Date.today.last_week
    flunk "@checking should be saved" unless @checking.save
    assert @checking.can_be_overrided?, "@good_checking should be overridabled because we are after the week of the checking date"
  end
  
  def test_override
    # when we are on the same week of (or before) the checking date (it's NOT ok)
    assert !@good_checking.override, "good_checking should NOT be overrided"
    
    # when we are after the week of the checking date (it's ok)
    @checking.attributes = @good_checking.attributes
    @checking.date = Date.today.last_week
    flunk "@checking should be savedd" unless @checking.save
    assert @checking.override, "checking should be overrided successfully"
  end
  
  def test_can_be_cancelled
    # when the checking is not already cancelled
    assert @good_checking.can_be_cancelled?, "@good_checking should be cancellable"
    
    flunk "@good_checking should be cancelled successfully" unless @good_checking.cancel
    
    assert !@good_checking.can_be_cancelled?, "@good_checking should NOT be cancellable"
  end
  
  def test_cancel
    assert @good_checking.cancel, "@good_checking should be cancelled"
    assert !@good_checking.cancel, "@good_checking should NOT be cancelled"
  end
  
  def test_verify_time
    @checking.attributes = checkings(:good_checking).attributes
    @checking.overtime_hours = 25
    @checking.absence_hours = 25
    @checking.overtime_minutes = 70
    @checking.absence_minutes = 70
    @checking.valid?
    assert @checking.errors.invalid?(:overtime_hours), "overtime_hours should NOT be valid because is greater than 23"
    assert @checking.errors.invalid?(:absence_hours), "morning_overtime_hours should NOT be valid because is greater than 23"
    assert @checking.errors.invalid?(:overtime_minutes), "overtime_minutes should NOT be valid because is greater than 59"
    assert @checking.errors.invalid?(:absence_minutes), "afternoon_overtime_minutes should NOT be valid because is greater than 59"
  end
  
  def test_get_float_hour
    {3.5 => [3, 30], 0.5 => [0, 30], 1.0 => [1, 0], 0.25 => [0, 15]}.each_pair do |float_value, time_value|
      assert_equal float_value, @good_checking.get_float_hour(time_value[0], time_value[1]), "#{time_value[0]}:#{time_value[1]} should be equal to #{float_value} h"
    end
  end
  
  def test_mandatory_comment
    assert @good_checking.mandatory_comment?(1,1), "mandatory_comment should return true, hours:1 ,minutes:1"
    assert @good_checking.mandatory_comment?(1,0), "mandatory_comment should return true, hours:1 ,minutes:0"
    assert @good_checking.mandatory_comment?(1,nil), "mandatory_comment should return true, hours:1 ,minutes:nil"
    assert !@good_checking.mandatory_comment?(nil,nil), "mandatory_comment should return false, hours:nil ,minutes:nil"
    assert !@good_checking.mandatory_comment?(0,nil), "mandatory_comment should return false, hours:0 ,minutes:nil"
    assert !@good_checking.mandatory_comment?(0,0), "mandatory_comment should return false, hours:0 ,minutes:0"
  end
  
  def test_not_empty_checking_with_no_fields
    [:absence_hours, :overtime_hours, :absence_minutes, :overtime_minutes].each do |attribute|
      assert @checking.errors.invalid?(attribute), "#{attribute} should NOT be valid"
    end 
  end
  
  def test_not_empty_checking_with_many_fields 
    [:absence_hours, :overtime_hours, :absence_minutes, :overtime_minutes].each do |attribute|
      assert !@good_checking.errors.invalid?(attribute), "#{attribute} should be valid"
    end
  end
  
  def test_not_empty_checking_with_hour_field
    @checking.absence_hours = 1
    @checking.valid?
    [:absence_hours, :overtime_hours, :absence_minutes, :overtime_minutes].each do |attribute|
      assert !@checking.errors.invalid?(attribute), "#{attribute} should be valid"
    end
  end
  
  def test_not_empty_checking_with_minutes_field  
    @checking.overtime_minutes = 3
    @checking.valid?
    [:absence_hours, :overtime_hours, :absence_minutes, :overtime_minutes].each do |attribute|
      assert !@checking.errors.invalid?(attribute), "#{attribute} should be valid"
    end
  end  

  def test_date_not_too_far_away
    @checking.date = Date.today
    @checking.valid?
    assert !@checking.errors.invalid?(:date), "date should be valid because date == today"
    
    @checking.date = Date.today + 1.week
    @checking.valid?
    assert !@checking.errors.invalid?(:date), "date should be valid because date isn't too far away"
    
    @checking.date = Date.today - 1.week
    @checking.valid?
    assert !@checking.errors.invalid?(:date), "date should be valid because date isn't too far away"
    
    @checking.date = Date.today + 2.month
    @checking.valid?
    assert @checking.errors.invalid?(:date), "date should be valid because date is too far away"
    
    @checking.date = Date.today - 1.month - 1.day
    @checking.valid?
    assert @checking.errors.invalid?(:date), "date should be valid because date is too far away"
  end
end
