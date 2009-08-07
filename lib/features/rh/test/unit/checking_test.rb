require 'test/test_helper'

class CheckingTest < ActiveSupport::TestCase
  
  def setup
    @good_checking = checkings(:good_checking)
    flunk "good cheking is not valid #{@good_checking.errors.inspect}" unless @good_checking.valid?
    
    @good_checking_with_morning_absence = checkings(:good_checking_with_morning_absence)
    @good_checking_with_morning_absence.valid?
    
    @good_checking_with_afternoon_absence = checkings(:good_checking_with_afternoon_absence)
    @good_checking_with_afternoon_absence.valid?
    
    @good_checking_with_day_absence = checkings(:good_checking_with_day_absence)
    @good_checking_with_day_absence.valid?
    
    @bad_checking_with_morning_absence = checkings(:bad_checking_with_morning_absence)
    @bad_checking_with_morning_absence.valid?
    
    @bad_checking_with_afternoon_absence = checkings(:bad_checking_with_afternoon_absence)
    @bad_checking_with_afternoon_absence.valid?
    
    @bad_checking_with_day_absence = checkings(:bad_checking_with_day_absence)
    @bad_checking_with_day_absence.valid?
    
    @comment_checking = checkings(:good_checking) # good checking used to test comments
    @comment_checking.valid?
    
    @checking = Checking.new
    @checking.valid?
  end
  
  def teardown
    @good_checking = nil
    @checking = nil
  end
  
  def test_numericality_of_absence
    assert !@checking.errors.invalid?(:absence), "absence should be valid"
    
    @checking.absence = "string"
    @checking.valid?
    assert @checking.errors.invalid?(:absence), "absence should NOT be valid because it's not a numerical value"
    assert !@good_checking.errors.invalid?(:absence), "absence should be valid"
  end
  
  # morning_overtime
  
  def test_numericality_of_morning_overtime_hours
    assert !@checking.errors.invalid?(:morning_overtime_hours), "morning_overtime_hours should be valid because nil is allowed"
    
    @checking.morning_overtime_hours = "string"
    @checking.valid?
    assert @checking.errors.invalid?(:morning_overtime_hours), "morning_overtime_hours should NOT be valid because it's not a numerical value"
    assert !@good_checking.errors.invalid?(:morning_overtime_hours), "morning_overtime_hours should be valid"
  end
  
  def test_numericality_of_morning_overtime_minutes
    assert !@checking.errors.invalid?(:morning_overtime_minutes), "morning_overtime_min should be valid because nil is allowed"
    
    @checking.morning_overtime_minutes = "string"
    @checking.valid?
    assert @checking.errors.invalid?(:morning_overtime_minutes), "morning_overtime_minutes should NOT be valid because it's not a numerical value"
    assert !@good_checking.errors.invalid?(:morning_overtime_minutes), "morning_overtime_minutes should be valid"
  end
  
  # afternoon_overtime
  
  def test_numericality_of_afternoon_overtime_hours
    assert !@checking.errors.invalid?(:afternoon_overtime_hours), "afternoon_overtime_hours should NOT be valid because nil is allowed"
    
    @checking.afternoon_overtime_hours = "string"
    @checking.valid?
    assert @checking.errors.invalid?(:afternoon_overtime_hours), "afternoon_overtime_hours should NOT be valid because it's not a numerical value"
    assert !@good_checking.errors.invalid?(:afternoon_overtime_hours), "afternoon_overtime_hours should be valid"
  end
  
  def test_numericality_of_afternoon_overtime_minutes
    assert !@checking.errors.invalid?(:afternoon_overtime_minutes), "afternoon_overtime_minutes should NOT be valid because nil is allowed"
    
    @checking.afternoon_overtime_minutes = "string"
    @checking.valid?
    assert @checking.errors.invalid?(:afternoon_overtime_minutes), "afternoon_overtime_minutes should NOT be valid because it's not a numerical value"
    assert !@good_checking.errors.invalid?(:afternoon_overtime_minutes), "afternoon_overtime_minutes should be valid"
  end
  
  # morning_delay
  
  def test_numericality_of_morning_delay_hours
    assert !@checking.errors.invalid?(:morning_delay_hours), "morning_delay_hours should NOT be valid because nil is allowed"
    
    @checking.morning_delay_hours = "string"
    @checking.valid?
    assert @checking.errors.invalid?(:morning_delay_hours), "morning_delay_hours should NOT be valid because it's not a numerical value"
    assert !@good_checking.errors.invalid?(:morning_delay_hours), "morning_delay_hours should be valid"
  end
  
  def test_numericality_of_morning_delay_minutes
    assert !@checking.errors.invalid?(:morning_delay_minutes), "morning_delay_minutes should NOT be valid because nil is allowed"
    
    @checking.morning_delay_minutes = "string"
    @checking.valid?
    assert @checking.errors.invalid?(:morning_delay_minutes), "morning_delay_minutes should NOT be valid because it's not a numerical value"
    assert !@good_checking.errors.invalid?(:morning_delay_minutes), "morning_delay_minutes should be valid"
  end
  
  # afternoon_delay
  
  def test_numericality_of_afternoon_delay_hours
    assert !@checking.errors.invalid?(:afternoon_delay_hours), "afternoon_delay_hours should NOT be valid because nil is allowed"
    
    @checking.afternoon_delay_hours = "string"
    @checking.valid?
    assert @checking.errors.invalid?(:afternoon_delay_hours), "afternoon_delay_hours should NOT be valid because it's not a numerical value"
    assert !@good_checking.errors.invalid?(:afternoon_delay_hours), "afternoon_delay_hours should be valid"
  end
  
  def test_numericality_of_afternoon_delay_minutes
    assert !@checking.errors.invalid?(:afternoon_delay_minutes), "afternoon_delay_minutes should NOT be valid because nil is allowed"
    
    @checking.afternoon_delay_minutes = "string"
    @checking.valid?
    assert @checking.errors.invalid?(:afternoon_delay_minutes), "afternoon_delay_minutes should NOT be valid because it's not a numerical value"
    assert !@good_checking.errors.invalid?(:afternoon_delay_minutes), "afternoon_delay_minutes should be valid"
  end
  
  ####

  def test_presence_of_absence_comment
    assert !@comment_checking.errors.invalid?(:absence_comment), "absence_comment should be valid"
    
    @comment_checking.absence_comment = nil
    @comment_checking.absence = 2
    @comment_checking.valid?
    assert @comment_checking.errors.invalid?(:absence_comment), "absence_comment should NOT be valid because it's nil"
    
    @comment_checking.absence = nil
    @comment_checking.valid?
    assert !@comment_checking.errors.invalid?(:absence_comment), "absence_comment should be valid because it still not mandatory"
  end
  
  def test_presence_of_morning_overtime_comment
    assert !@comment_checking.errors.invalid?(:morning_overtime_comment), "morning_overtime_comment should be valid"
    
    @comment_checking.morning_overtime_comment = nil
    @comment_checking.morning_overtime_hours = 2
    @comment_checking.valid?
    assert @comment_checking.errors.invalid?(:morning_overtime_comment), "morning_overtime_comment should NOT be valid because it's nil"
    
    @comment_checking.morning_overtime_hours = nil
    @comment_checking.morning_overtime_minutes = nil
    @comment_checking.valid?
    assert !@comment_checking.errors.invalid?(:morning_overtime_comment), "morning_overtime_comment should be valid because it still not mandatory"
  end
  
  def test_presence_of_morning_delay_comment
    assert !@comment_checking.errors.invalid?(:absence_comment), "morning_delay_comment should be valid"
    
    @comment_checking.morning_delay_comment = nil
    @comment_checking.morning_delay_hours = 2
    @comment_checking.valid?
    assert @comment_checking.errors.invalid?(:morning_delay_comment), "morning_delay_comment should NOT be valid because it's nil"
    
    @comment_checking.morning_delay_hours = nil
    @comment_checking.morning_delay_minutes = nil
    @comment_checking.valid?
    assert !@comment_checking.errors.invalid?(:morning_delay_comment), "morning_delay_comment should be valid because it still not mandatory"
  end
  
  def test_presence_of_afternoon_overtime_comment
    assert !@comment_checking.errors.invalid?(:afternoon_overtime_comment), "afternoon_overtime_comment should be valid"
    
    @comment_checking.afternoon_overtime_comment = nil
    @comment_checking.afternoon_overtime_hours = 2
    @comment_checking.valid?
    assert @comment_checking.errors.invalid?(:afternoon_overtime_comment), "afternoon_overtime_comment should NOT be valid because it's nil"
    
    @comment_checking.afternoon_overtime_hours = nil
    @comment_checking.afternoon_overtime_minutes = nil
    @comment_checking.valid?
    assert !@comment_checking.errors.invalid?(:afternoon_overtime_comment), "afternoon_overtime_comment should be valid because it still not mandatory"
  end
  
  def test_presence_of_afternoon_delay_comment
    assert !@comment_checking.errors.invalid?(:afternoon_delay_comment), "afternoon_delay_comment should be valid"
    
    @comment_checking.afternoon_delay_comment = nil
    @comment_checking.afternoon_delay_hours = 2
    @comment_checking.valid?
    assert @comment_checking.errors.invalid?(:afternoon_delay_comment), "afternoon_delay_comment should NOT be valid because it's nil"
    
    @comment_checking.afternoon_delay_hours = nil
    @comment_checking.afternoon_delay_minutes = nil
    @comment_checking.valid?
    assert !@comment_checking.errors.invalid?(:afternoon_delay_comment), "afternoon_delay_comment should be valid because it still not mandatory"
  end

  
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
    @checking.date += 1.day
    @checking.valid?
    assert !@checking.errors.invalid?(:date), "date should be valid"
    assert !@checking.errors.invalid?(:employee_id), "employee_id should be valid"
    
    # same date but change the employee
    @checking = Checking.new(checkings(:good_checking).attributes)
    @checking.employee = employees(:james_doe)
    @checking.valid?
    assert !@checking.errors.invalid?(:date), "date should be valid"
    assert !@checking.errors.invalid?(:employee_id), "employee_id should be valid"
  end
  
  def test_restricted_edit
    @good_checking.absence_comment = "another comment"
    @good_checking.valid?
    assert !@good_checking.errors.invalid?(:date), "date should be valid because is not modified"
    assert !@good_checking.errors.invalid?(:employee_id), "employee_id should be valid because is not modified"
    
    @good_checking.date += 1.day
    @good_checking.valid?
    assert @good_checking.errors.invalid?(:date), "date should NOT be valid because is modified"
    assert !@good_checking.errors.invalid?(:employee_id), "employee_id should be valid because is not modified"
    
    @good_checking.reload
    @good_checking.employee_id = employees(:james_doe).id
    @good_checking.valid?
    assert !@good_checking.errors.invalid?(:date), "date should be valid because is not modified"
    assert @good_checking.errors.invalid?(:employee_id), "employee_id should NOT be valid because is modified"    
  end
  
  def test_correlation_between_absence_and_other_datas_with_morning_absence
    assert !@good_checking.errors.invalid?(:morning_delay_hours), "morning_delay_hours should be valid because there's no absence"
    assert !@good_checking.errors.invalid?(:morning_delay_minutes), "morning_delay_minutes should be valid because there's no absence"
    assert !@good_checking.errors.invalid?(:morning_overtime_minutes), "morning_overtime_minutes should be valid there's no absence"
    assert !@good_checking.errors.invalid?(:morning_overtime_hours), "morning_overtime_hours should be valid there's no absence"
    
    assert !@good_checking_with_morning_absence.errors.invalid?(:morning_delay_hours), "morning_delay_hours should be valid"
    assert !@good_checking_with_morning_absence.errors.invalid?(:morning_delay_minutes), "morning_delay_minutes should be valid"
    assert !@good_checking_with_morning_absence.errors.invalid?(:morning_overtime_hours), "morning_overtime_hours should be valid"
    assert !@good_checking_with_morning_absence.errors.invalid?(:morning_overtime_minutes), "morning_overtime_minutes should be valid"
    assert @bad_checking_with_morning_absence.errors.invalid?(:morning_delay_hours), "morning_delay_hours should NOT be valid"
    assert @bad_checking_with_morning_absence.errors.invalid?(:morning_delay_minutes), "morning_delay_minutes should NOT be valid"
    assert @bad_checking_with_morning_absence.errors.invalid?(:morning_overtime_hours), "morning_overtime_hours should NOT be valid"
    assert @bad_checking_with_morning_absence.errors.invalid?(:morning_overtime_minutes), "morning_overtime_minutes should NOT be valid"
  end
  
  def test_correlation_between_absence_and_other_datas_with_afternoon_absence
    assert !@good_checking.errors.invalid?(:afternoon_delay_hours), "afternoon_delay_hours should be valid there's no absence"
    assert !@good_checking.errors.invalid?(:afternoon_delay_minutes), "afternoon_delay_minutes should be valid there's no absence"
    assert !@good_checking.errors.invalid?(:afternoon_overtime_hours), "afternoon_overtime_hours should be valid there's no absence"
    assert !@good_checking.errors.invalid?(:afternoon_overtime_minutes), "afternoon_overtime_minutes should be valid there's no absence"
    
    assert !@good_checking_with_afternoon_absence.errors.invalid?(:afternoon_delay_hours), "afternoon_delay_hours should be valid"
    assert !@good_checking_with_afternoon_absence.errors.invalid?(:afternoon_delay_minutes), "afternoon_delay_minutes should be valid"
    assert !@good_checking_with_afternoon_absence.errors.invalid?(:afternoon_overtime_hours), "afternoon_overtime_hours should be valid"
    assert !@good_checking_with_afternoon_absence.errors.invalid?(:afternoon_overtime_minutes), "afternoon_overtime_minutes should be valid"
    assert @bad_checking_with_afternoon_absence.errors.invalid?(:afternoon_delay_hours), "afternoon_delay_hours should NOT be valid"
    assert @bad_checking_with_afternoon_absence.errors.invalid?(:afternoon_delay_minutes), "afternoon_delay_minutes should NOT be valid"
    assert @bad_checking_with_afternoon_absence.errors.invalid?(:afternoon_overtime_hours), "afternoon_overtime_hours should NOT be valid"
    assert @bad_checking_with_afternoon_absence.errors.invalid?(:afternoon_overtime_minutes), "afternoon_overtime_minutes should NOT be valid"
  end
  
  def test_correlation_between_absence_and_other_datas_with_day_absence
    assert !@good_checking.errors.invalid?(:morning_delay_hours), "morning_delay_hours should be valid there's no absence"
    assert !@good_checking.errors.invalid?(:morning_overtime_hours), "morning_overtime_hours should be valid there's no absence"
    assert !@good_checking.errors.invalid?(:afternoon_delay_hours), "afternoon_delay_hours should be valid there's no absence"
    assert !@good_checking.errors.invalid?(:afternoon_overtime_hours), "afternoon_overtime_hours should be valid there's no absence"
    assert !@good_checking.errors.invalid?(:morning_delay_minutes), "morning_delay_minutes should be valid there's no absence"
    assert !@good_checking.errors.invalid?(:morning_overtime_minutes), "morning_overtime_minutes should be valid there's no absence"
    assert !@good_checking.errors.invalid?(:afternoon_delay_minutes), "afternoon_delay_minutes should be valid there's no absence"
    assert !@good_checking.errors.invalid?(:afternoon_overtime_minutes), "afternoon_overtime_minutes should be valid there's no absence"
    
    assert !@good_checking_with_day_absence.errors.invalid?(:morning_delay_hours), "morning_delay_hours should be valid"
    assert !@good_checking_with_day_absence.errors.invalid?(:morning_overtime_hours), "morning_overtime_hours should be valid"
    assert !@good_checking_with_day_absence.errors.invalid?(:afternoon_delay_hours), "afternoon_delay_hours should be valid"
    assert !@good_checking_with_day_absence.errors.invalid?(:afternoon_overtime_hours), "afternoon_overtime_hours should be valid"
    assert !@good_checking_with_day_absence.errors.invalid?(:morning_delay_minutes), "morning_delay_minutes should be valid"
    assert !@good_checking_with_day_absence.errors.invalid?(:morning_overtime_minutes), "morning_overtime_minutes should be valid"
    assert !@good_checking_with_day_absence.errors.invalid?(:afternoon_delay_minutes), "afternoon_delay_minutes should be valid"
    assert !@good_checking_with_day_absence.errors.invalid?(:afternoon_overtime_minutes), "afternoon_overtime_minutes should be valid"
    
    assert @bad_checking_with_day_absence.errors.invalid?(:morning_delay_hours), "morning_delay_hours should NOT be valid"
    assert @bad_checking_with_day_absence.errors.invalid?(:morning_overtime_hours), "morning_overtime_hours should NOT be valid"
    assert @bad_checking_with_day_absence.errors.invalid?(:afternoon_delay_hours), "afternoon_delay_hours should NOT be valid"
    assert @bad_checking_with_day_absence.errors.invalid?(:afternoon_overtime_hours), "afternoon_overtime_hours should NOT be valid"
    assert @bad_checking_with_day_absence.errors.invalid?(:morning_delay_minutes), "morning_delay_minutes should NOT be valid"
    assert @bad_checking_with_day_absence.errors.invalid?(:morning_overtime_minutes), "morning_overtime_minutes should NOT be valid"
    assert @bad_checking_with_day_absence.errors.invalid?(:afternoon_delay_minutes), "afternoon_delay_minutes should NOT be valid"
    assert @bad_checking_with_day_absence.errors.invalid?(:afternoon_overtime_minutes), "afternoon_overtime_minutes should NOT be valid"
  end
  
  # test only for the the four main variables if the method works with them so it will work with the 8 others
  def test_verify_time
    @checking = Checking.new(checkings(:good_checking).attributes)
    @checking.morning_delay_hours = 25
    @checking.morning_overtime_hours = 25
    @checking.afternoon_delay_minutes = 70
    @checking.afternoon_overtime_minutes = 70
    @checking.valid?
    assert @checking.errors.invalid?(:morning_delay_hours), "morning_delay_hours should NOT be valid because is greater than 23"
    assert @checking.errors.invalid?(:morning_overtime_hours), "morning_overtime_hours should NOT be valid because is greater than 23"
    assert @checking.errors.invalid?(:afternoon_delay_minutes), "afternoon_delay_minutes should NOT be valid because is greater than 59"
    assert @checking.errors.invalid?(:afternoon_overtime_minutes), "afternoon_overtime_minutes should NOT be valid because is greater than 59"
  end
  
  def test_get_float_hour
    {3.5 => [3, 30], 0.5 => [0, 30], 1.0 => [1, 0], 0.25 => [0, 15]}.each_pair do |float_value, time_value|
      assert_equal float_value, @good_checking.get_float_hour(time_value[0], time_value[1]), "#{time_value[0]}:#{time_value[1]} should be equal to #{float_value} h"
    end
  end
  
  def test_mandatory_comment
    assert_equal true, mandatory_comment(1,1), "mandatory_comment should return true, hours:1 ,minutes:1"
    assert_equal true, mandatory_comment(1,0), "mandatory_comment should return true, hours:1 ,minutes:0"
    assert_equal true, mandatory_comment(1,nil), "mandatory_comment should return true, hours:#{1} ,minutes:#{nil}"
    assert_equal false, mandatory_comment(nil,nil), "mandatory_comment should return false, hours:#{nil} ,minutes:#{nil}"
    assert_equal false, mandatory_comment(0,nil), "mandatory_comment should return false, hours:#{0} ,minutes:#{nil}"
    assert_equal false, mandatory_comment(0,0), "mandatory_comment should return false, hours:#{0} ,minutes:#{0}"
  end
  
end
