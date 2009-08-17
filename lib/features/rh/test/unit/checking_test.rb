require 'test/test_helper'

class CheckingTest < ActiveSupport::TestCase
  
  def setup
    @good_checking = checkings(:good_checking)
    flunk "good cheking is not valid #{@good_checking.errors.inspect}" unless @good_checking.valid?
    @checking = Checking.new
    @checking.valid?
  end
  
  def teardown
    @good_checking = nil
    @checking = nil
  end
  
  # overtime
  
  def test_numericality_of_overtime_hours
    assert !@checking.errors.invalid?(:overtime_hours), "overtime_hours should NOT be valid because nil is allowed"
    
    @checking.overtime_hours = "string"
    @checking.valid?
    assert @checking.errors.invalid?(:overtime_hours), "overtime_hours should NOT be valid because it's not a numerical value"
    assert !@good_checking.errors.invalid?(:overtime_hours), "overtime_hours should be valid"
  end
  
  def test_numericality_of_overtime_minutes
    assert !@checking.errors.invalid?(:overtime_minutes), "overtime_minutes should NOT be valid because nil is allowed"
    
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
    assert !@good_checking.errors.invalid?(:overtime_comment), "overtime_comment should be valid because it still not mandatory"
  end
  
  # absence
  
  def test_numericality_of_absence_hours
    assert !@checking.errors.invalid?(:absence_hours), "absence_hours should NOT be valid because nil is allowed"
    
    @checking.absence_hours = "string"
    @checking.valid?
    assert @checking.errors.invalid?(:absence_hours), "absence_hours should NOT be valid because it's not a numerical value"
    assert !@good_checking.errors.invalid?(:absence_hours), "absence_hours should be valid"
  end
  
  def test_numericality_of_absence_minutes
    assert !@checking.errors.invalid?(:absence_minutes), "absence_minutes should NOT be valid because nil is allowed"
    
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
    assert !@good_checking.errors.invalid?(:absence_comment), "absence_comment should be valid because it still not mandatory"
  end
  
  ####
    
  def test_presence_of_date
    assert @checking.errors.invalid?(:date), "employee_id should NOT be valid because it's nil"
    assert !@good_checking.errors.invalid?(:date), "employee_id should be valid"
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
    @checking = Checking.new(checkings(:good_checking).attributes)
    @checking.valid?
    assert @checking.errors.invalid?(:date), "date should NOT be valid because the couple (date, employee_id) already exists"
    assert @checking.errors.invalid?(:employee_id), "employee_id should NOT be valid because the couple (date, employee_id) already exists"
    
    # same employee but change the date
    @checking.date -= 1.day
    @checking.valid?
    assert !@checking.errors.invalid?(:date), "date should be valid"
    assert !@checking.errors.invalid?(:employee_id), "employee_id should be valid"
    
    # same date but change the employee
    @checking = Checking.new(checkings(:good_checking).attributes)
    @checking.employee = employees(:another_employee)
    @checking.valid?
    assert !@checking.errors.invalid?(:date), "date should be valid"
    assert !@checking.errors.invalid?(:employee_id), "employee_id should be valid"
  end
  
  def test_modification_period_limit
    # 6 day ago -> less than 1 week (use new record because it is forbidden to modify the date)
    @good_checking.absence_comment = "modification limit test"
    assert_equal true, @good_checking.valid?, "good_checking should be valid because checking isn't too late"
    
    # 2 weeks ago -> more than 1 week (use new record because it is forbidden to modify the date)
    @good_checking.created_at = (Date.today - 2.week).to_datetime
    @good_checking.absence_comment = "modification limit test"
    assert_equal false, @good_checking.valid?, "good_checking should NOT be valid because checking isn't too late"
  end
  
  def test_override
    assert_equal false, @good_checking.override, "good_checking should NOT be valid because the cweek is equal to the created_at one"
    @good_checking.created_at = Date.today.last_week.to_datetime
    assert_equal true, @good_checking.override, "good_checking should be valid"
  end
  
  def test_restricted_edit
    assert_equal true, @good_checking.valid?, "good_checking should NOT be valid"
    @good_checking.created_at = Date.today.last_week.to_datetime
    assert_equal false, @good_checking.valid?, "good_checking should NOT be valid because the cweek is not equal to the created_at one"
  end
  
  def test_verify_fixed_attributes
    @good_checking.absence_comment = "another comment"
    @good_checking.valid?
    assert !@good_checking.errors.invalid?(:date), "date should be valid because is not modified"
    assert !@good_checking.errors.invalid?(:employee_id), "employee_id should be valid because is not modified"
    assert !@good_checking.errors.invalid?(:user_id), "user_id should be valid because is not modified"
    
    # try to modify the date
    @good_checking.reload
    @good_checking.date -= 1.day
    @good_checking.valid?
    assert @good_checking.errors.invalid?(:date), "date should NOT be valid because is modified"
    assert !@good_checking.errors.invalid?(:employee_id), "employee_id should be valid because is not modified"
    assert !@good_checking.errors.invalid?(:user_id), "user_id should be valid because is not modified"
    
    # try to modify the employee_id
    @good_checking.reload
    @good_checking.employee_id = employees(:james_doe).id
    @good_checking.valid?
    assert !@good_checking.errors.invalid?(:date), "date should be valid because is not modified"
    assert @good_checking.errors.invalid?(:employee_id), "employee_id should NOT be valid because is modified"
    assert !@good_checking.errors.invalid?(:user_id), "user_id should be valid because is not modified"
    
    # try to modify the user_id
    @good_checking.reload
    @good_checking.user_id = users(:admin_user).id
    @good_checking.valid?
    assert !@good_checking.errors.invalid?(:date), "date should be valid because is not modified"
    assert !@good_checking.errors.invalid?(:employee_id), "employee_id should NOT be valid because is modified"
    assert @good_checking.errors.invalid?(:user_id), "user_id should be valid because is not modified"
  end
    
  def test_validate_cancel_flag
    @good_checking.cancelled = true
    @good_checking.valid?
    assert @good_checking.errors.invalid?(:cancelled), "cancelled should NOT be valid because is modified while a normal edit"
    
    @good_checking.reload
    assert_equal true, @good_checking.cancel, "cancelled should be valid because is modified while a cancel"
  end
  
  def test_verify_time
    @checking = Checking.new(checkings(:good_checking).attributes)
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
    assert_equal true, @good_checking.mandatory_comment?(1,1), "mandatory_comment should return true, hours:1 ,minutes:1"
    assert_equal true, @good_checking.mandatory_comment?(1,0), "mandatory_comment should return true, hours:1 ,minutes:0"
    assert_equal true, @good_checking.mandatory_comment?(1,nil), "mandatory_comment should return true, hours:1 ,minutes:nil"
    assert_equal false, @good_checking.mandatory_comment?(nil,nil), "mandatory_comment should return false, hours:nil ,minutes:nil"
    assert_equal false, @good_checking.mandatory_comment?(0,nil), "mandatory_comment should return false, hours:0 ,minutes:nil"
    assert_equal false, @good_checking.mandatory_comment?(0,0), "mandatory_comment should return false, hours:0 ,minutes:0"
  end
  
  def test_not_empty_checking
    @empty_checking = checkings(:empty_checking)
    # no fields
    assert_equal false, @empty_checking.valid?, "empty_checking should NOT be valid"
    
    # many fields
    assert_equal true, @good_checking.valid?, "empty_checking should be valid #{@empty_checking.errors.inspect}"
    
    # only one field => hours
    @empty_checking.absence_hours = 1
    assert_equal true, @empty_checking.valid?, "empty_checking should be valid #{@empty_checking.errors.inspect}"
    
    # only one field => minutes
    @empty_checking.absence_hours = nil
    @empty_checking.overtime_minutes = 3
    assert_equal true, @empty_checking.valid?, "empty_checking should be valid #{@empty_checking.errors.inspect}"
    
    # only one field => minutes
    @empty_checking.overtime_hours = nil
    @empty_checking.overtime_minutes = 3
    assert_equal true, @empty_checking.valid?, "empty_checking should be valid #{@empty_checking.errors.inspect}"
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
