require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase
  fixtures :employees, :civilities

  def setup
    @good_employee = employees(:james_doe)
    @employee_with_job = employees(:johnny)
    @employee_with_job.jobs << jobs(:responsible_job)
    #@leave_days_credit_per_month = ConfigurationManager.admin_society_identity_configuration_leave_days_credit_per_month
    @default_leave = Leave.new(:start_date => (Date.today - 11.month) + 3.month,
                                 :end_date => (Date.today - 11.month) + 3.month + 6.days,
                                 :duration => 7.0,
                                 :leave_type_id => LeaveType.first.id,
                                 :leave_request_id => LeaveRequest.first.id)
    @default_leave.save 
    @employee = Employee.new
  end

  def test_read
    assert_nothing_raised "An Employee should be read" do
      Employee.find(@good_employee.id)
    end
  end
  
  def test_create
    assert_difference 'Employee.count', +1, "Employee should be created" do
      e = Employee.create(@good_employee.attributes)
    end
  end

  def test_delete
    assert_difference 'Employee.count', -1, "An Employee should be destroy" do
      @good_employee.destroy
    end
  end

  def test_presence_of_last_name
    assert_no_difference 'Employee.count' do
      employee = Employee.create
      assert_not_nil employee.errors.on(:last_name),
        "An Employee should have a last name"
    end
  end

  def test_presence_of_first_name
    assert_no_difference 'Employee.count' do
      employee = Employee.create
      assert_not_nil employee.errors.on(:first_name),
        "An Employee should have a first name"
    end
  end

  def test_format_of_social_security_number
    assert_no_difference 'Employee.count' do
      employee = Employee.create(:social_security_number => 'a')
      assert_not_nil employee.errors.on(:social_security_number),
        "An Employee should have a correct social security number"
    end
  end

  def test_format_of_email
    assert_no_difference 'Employee.count' do
      employee = Employee.create(:email => 'peter@on_bird')
      assert_not_nil employee.errors.on(:email),
        "An Employee should have a correct email"
    end
  end

  def test_format_of_society_email
    assert_no_difference 'Employee.count' do
      employee = Employee.create(:society_email => 'peter@on_another_bird')
      assert_not_nil employee.errors.on(:society_email),
        "An Employee should have a correct society email"
    end
  end
  
#  # get leave_days_left from an employee without leaves to get the total
#  def test_get_total_leave_days_method_for_one_year
#    ConfigurationManager.admin_society_identity_configuration_leave_year_start_date = (Date.today - 11.month).strftime("%m/%d")  
#    assert_equal @employee.get_total_leave_days, @leave_days_credit_per_month*12, "should be equal to #{@leave_days_credit_per_month*12} for one year"
#  end
#  
#  # get leave_days_left from an employee without leaves to get the total
#  def test_get_total_leave_days_method_for_six_months
#    ConfigurationManager.admin_society_identity_configuration_leave_year_start_date = (Date.today - 5.month).strftime("%m/%d")
#    assert_equal @employee.get_total_leave_days, @leave_days_credit_per_month*6, "should be equal to #{@leave_days_credit_per_month*6} for 1/2 year"
#  end
#  
#  
#  def test_leaves_days_left_method_with_one_standard_leave
#    leave_year_start = prepare_contextual_variables
#    @good_employee.leaves.new(:start_date => leave_year_start + 3.month,
#                                :end_date => leave_year_start + 3.month + 6.days,
#                                :leave_type_id => LeaveType.first.id).save
#    test_with_fixed_duration(7) # 7 because the leave is about one week from monday to sunday
#  end
#  
#  def test_leave_days_left_method_with_a_leave_starting_before_year_start
#    leave_year_start = prepare_contextual_variables
#    @good_employee.leaves.new(:start_date => leave_year_start - 2.days,
#                                :end_date => leave_year_start + 4.days,
#                                :leave_type_id => LeaveType.first.id).save
#    test_with_fixed_duration(5) # 5 because there's 2 days that don't belongs to the current leave year
#  end
#  
#  def test_leave_days_left_method_with_a_leave_finishing_after_year_end
#    leave_year_start = prepare_contextual_variables
#    reference = leave_year_start + 1.year - 1.day
#    @good_employee.leaves.new(:start_date => reference - 2.days,
#                                :end_date => reference + 4.days,
#                                :leave_type_id => LeaveType.first.id).save
#    test_with_fixed_duration(3) # 3 because there's 4 days that don't belongs to the current leave year
#  end
  
  #FIXME if today.month == December it may not work because the start cannot be past year (1.year = 12.months and december == 12e month)
  def test_get_leave_year_method_for_past_year
    ConfigurationManager.admin_society_identity_configuration_leave_year_start_date = "#{Date.today.month + 1}/#{Date.today.day}"
    assert_equal Date.today.year-1, Employee.get_leave_year_start_date.year, "leave_year_start_date should be equal to #{Date.today.year-1}"
  end
  
  def test_get_leave_year_method_for_current_year
    ConfigurationManager.admin_society_identity_configuration_leave_year_start_date = "#{Date.today.month}/#{Date.today.day}"
    assert_equal Date.today.year, Employee.get_leave_year_start_date.year, "leave_year_start_date should be equal to #{Date.today.year}"
  end
  
  def test_get_leaves_for_choosen_year_method
    leave_year_start = prepare_contextual_variables
    # add some leaves to good_employee different number of leaves for each leave year as (n-1 | n | n+1) where 'n' is current leave year
    
    # 1 leave into past year
    @good_employee.leaves.new(:start_date => leave_year_start - 1.year,
                                  :end_date => leave_year_start - 1.year + 4.days,
                                  :duration => 5.0,
                                  :leave_type_id => LeaveType.first.id,
                                  :leave_request_id => LeaveRequest.first.id).save
        
    # 2 leaves into current year
    2.times do
      @good_employee.leaves.new(:start_date => leave_year_start,
                                  :end_date => leave_year_start + 4.days,
                                  :duration => 5.0,
                                  :leave_type_id => LeaveType.first.id,
                                  :leave_request_id => LeaveRequest.first.id).save
    end
    
    # 3 leaves into next year
    3.times do
      @good_employee.leaves.new(:start_date => leave_year_start + 1.year,
                                  :end_date => leave_year_start + 1.year + 4.days,
                                  :duration => 5.0,
                                  :leave_type_id => LeaveType.first.id,
                                  :leave_request_id => LeaveRequest.first.id).save
    end
    flunk "error with leaves" if @good_employee.leaves.empty?
    assert_equal 1, @good_employee.get_leaves_for_choosen_year(-1).size, "it should have 1 leave for past year"
    assert_equal 2, @good_employee.get_leaves_for_choosen_year(0).size, "it should have 2 leaves for current year"
    assert_equal 3, @good_employee.get_leaves_for_choosen_year(1).size, "it should have 3 leaves for next year"
  end
  
  def test_services_under_responsibility
    assert @good_employee.services_under_responsibility.empty?, "good_employee should NOT have service under his responsibility"
    
    assert_equal 1, @employee_with_job.services_under_responsibility.size, "employee_with_job should have 1 service under his responsibility"
    
    @employee_with_job.jobs << jobs(:responsible_job)
    assert_equal 2, @employee_with_job.services_under_responsibility.size, "employee_with_job should have 2 services under his responsibility"
  end
  
  def test_subordinates
    assert @good_employee.subordinates.empty?, "good_employee should NOT have subordinates"
    assert_equal 1, @employee_with_job.subordinates.size, "employee_with_job should have 1 subordinate because james_doe belongs to direction_general that is a service under his responsability"
  end
  
  private 
    
#    def test_with_fixed_duration(duration)
#      leave_duration = duration
#      wanted_leaves_days_left = @leave_days_credit_per_month*12 - leave_duration
#      assert_equal @good_employee.leaves_days_left, wanted_leaves_days_left, "should be equal to #{wanted_leaves_days_left} for one year and with 1 leave of #{duration} days #{@good_employee.leaves.first.duration}"
#    end
    
    def prepare_contextual_variables
      ConfigurationManager.admin_society_identity_configuration_workable_days = "1234560".split("")
      ConfigurationManager.admin_society_identity_configuration_leave_year_start_date = (Date.today - 11.month).strftime("%m/%d")
      return (Date.today - 11.month)
    end
end
