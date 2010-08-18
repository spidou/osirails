require File.dirname(__FILE__) + '/../rh_test'

class EmployeeTest < ActiveSupport::TestCase
  should_journalize :attributes => [:birth_date, :first_name, :last_name, :civility_id], :attachments => :avatar, :subresources => [:address, :numbers, {:jobs => :create_and_destroy}]

  should_belong_to :family_situation, :civility, :user, :service

  should_have_one :iban, :job_contract

  should_have_many :contacts_owners
  should_have_many :contacts, :through => :contacts_owners
  should_have_many :premia, :employees_jobs
  should_have_many :jobs, :through => :employees_jobs
  should_have_many :checkings, :leaves, :leave_requests

  should_have_many :in_progress_leave_requests, :accepted_leave_requests, :refused_leave_requests, :cancelled_leave_requests

  should_validate_presence_of :last_name, :first_name
  should_validate_presence_of :family_situation, :civility, :service, :with_foreign_key => :default

  should_allow_values_for :social_security_number, "1234567890123 45", "0123456789012 34"
  should_not_allow_values_for :social_security_number, nil, "", "1", "0123456789012 3", "012345678901 34", "123456789012345", :message => "Le numéro de sécurité sociale doit comporter 15 chiffres"

  should_allow_values_for :email, nil, "", "foo@bar.com", "foo.bar@bar.fr", "foo@bar.abcde"
  should_not_allow_values_for :email, "@foo.com", "foo@", "foo@b", "foo@bar", "foo@bar.", "foo@bar.c", "foot@bar.abcdef", :message => "L'adresse e-mail est incorrecte"

  should_allow_values_for :society_email, nil, "", "foo@bar.com", "foo.bar@bar.fr", "foo@bar.abcde"
  should_not_allow_values_for :society_email, "@foo.com", "foo@", "foo@b", "foo@bar", "foo@bar.", "foo@bar.c", "foot@bar.abcdef", :message => "L'adresse e-mail entreprise est incorrecte"

  def setup
    @good_employee = employees(:james_doe)
    @employee_with_job = employees(:johnny)

    @employee = Employee.new
  end
  subject{ @employee } #this seems to be unused but its necessary to avoid warning from shoulda.

  def teardown
    @good_employee = nil
    @employee = nil
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
    ConfigurationManager.admin_society_identity_configuration_leave_year_start_date = "#{(Date.today + 1.month).month}/#{Date.today.day}"
    assert_equal Date.today.year-1, Employee.leave_year_start_date.year, "leave_year_start_date should be equal to #{Date.today.year-1}"
  end

  def test_get_leave_year_method_for_current_year
    ConfigurationManager.admin_society_identity_configuration_leave_year_start_date = "#{Date.today.month}/#{Date.today.day}"
    assert_equal Date.today.year, Employee.leave_year_start_date.year, "leave_year_start_date should be equal to #{Date.today.year}"
  end

  def test_get_leaves_for_choosen_year_method
    leave_year_start = prepare_contextual_variables
    # add some leaves to good_employee different number of leaves for each leave year as (n-1 | n | n+1) where 'n' is current leave year

    ## 1 leave into past year
    @good_employee.leaves.new(:start_date => leave_year_start - 1.year,
                              :end_date => leave_year_start - 1.year + 4.days,
                              :duration => 5.0,
                              :leave_type_id => LeaveType.first.id).save

    ## 2 leaves into current year
    2.times do |i|
      @good_employee.leaves.new(:start_date => leave_year_start + i.month,
                                :end_date => leave_year_start + 4.days + i.month,
                                :duration => 5.0,
                                :leave_type_id => LeaveType.first.id).save
    end

    ## 3 leaves into next year
    3.times do |i|
      @good_employee.leaves.new(:start_date => leave_year_start + 1.year + i.month,
                                :end_date => leave_year_start + 1.year + 4.days + i.month,
                                :duration => 5.0,
                                :leave_type_id => LeaveType.first.id).save
    end
    flunk "error with leaves" if @good_employee.leaves.empty?
    assert_equal 1, @good_employee.get_leaves_for_choosen_year(leave_year_start.last_year.year).size, "it should have 1 leave for past year"
    assert_equal 2, @good_employee.get_leaves_for_choosen_year(leave_year_start.year).size, "it should have 2 leaves for current year"
    assert_equal 3, @good_employee.get_leaves_for_choosen_year(leave_year_start.next_year.year).size, "it should have 3 leaves for next year"
  end

  def test_services_under_responsibility
    job_direction_responsible      = create_job_responsible("r1", services(:direction_general))
    job_administration_responsible = create_job_responsible("r2", services(:administration))

    assert @good_employee.services_under_responsibility.empty?, "good_employee should NOT have service under his responsibility"

    @employee_with_job.jobs << job_direction_responsible
    assert_equal 1, @employee_with_job.services_under_responsibility.size, "employee_with_job should have 1 service under his responsibility"

    @employee_with_job.jobs << job_direction_responsible
    assert_equal 1, @employee_with_job.services_under_responsibility.size, "employee_with_job should have 1 service under his responsibility even if there's two jobs"

    @employee_with_job.jobs << job_administration_responsible
    assert_equal 2, @employee_with_job.services_under_responsibility.size, "employee_with_job should have 2 services under his responsibility"
  end

  def test_responsible_job_limit
    job1 = create_job_responsible("responsible_job", services(:direction_general))

    # add a responsible for direction general service
    @employee_with_job.jobs << job1

    @good_employee.attributes = {:job_ids => [job1.id]}
    @good_employee.valid?
    assert !@good_employee.errors.invalid?(:jobs), "jobs should be valid because there's only 1 responsible for 'direction general' service"

    # add another responsible for direction general service
    @employee = employees(:franck_doe)
    @employee.jobs << job1

    @good_employee.valid?
    @good_employee.jobs.group_by(&:service).to_hash.values.first.size
    assert @good_employee.errors.invalid?(:jobs), "jobs should NOT be valid because there's too many responsibles for 'direction general' service"
  end

  def test_self_and_subordinates
    job_direction_responsible       = create_job_responsible("job_direction_responsible", services(:direction_general))
    job_administration_responsible  = create_job_responsible("job_administration_responsible", services(:administration))

    assert @good_employee.self_and_subordinates.empty?, "good_employee should NOT have subordinates"

    @employee_with_job.jobs << job_direction_responsible
    assert_equal 3, @employee_with_job.self_and_subordinates.size, "employee_with_job should have 3 people in self_and_subordinates because james_doe and trish_doe belongs to direction_general"

    # all sub_employees belongs to administration service
    @sub_employee_1 = employees(:franck_doe)
    @sub_employee_1.jobs << job_administration_responsible
    assert_equal 2, @sub_employee_1.self_and_subordinates.size, "sub_employee_1 should have 2"

    @sub_employee_3 = employees(:trish_doe)
    assert_equal 0, @sub_employee_3.self_and_subordinates.size, "sub_employee_3 should have 0"

    @employee_with_job.jobs << job_administration_responsible # employee_with_job is now configured as responsible of all sub employees below
    assert_equal 5, @employee_with_job.self_and_subordinates.size, "employee_with_job should have 5 people in self_and_subordinates 2 into direction_general and 2 in administration"
  end

  def test_subordinates
    job_direction_responsible      = create_job_responsible("r1", services(:direction_general))
    job_administration_responsible = create_job_responsible("r2", services(:administration))

    assert @good_employee.subordinates.empty?, "good_employee should NOT have subordinates"

    @employee_with_job.jobs << job_direction_responsible
    assert_equal 2, @employee_with_job.subordinates.size, "employee_with_job should have 2 subordinates because james_doe and trish_doe belongs to direction_general"

    # all sub_employees belongs to administration service
    @sub_employee_1 = employees(:franck_doe)
    @sub_employee_1.jobs << job_administration_responsible
    assert_equal 1, @sub_employee_1.subordinates.size, "sub_employee_1 should have 1 subordinate"

    @sub_employee_3 = employees(:trish_doe)
    assert_equal 0, @sub_employee_3.subordinates.size, "sub_employee_3 should have 0 subordinate"

    @employee_with_job.jobs << job_administration_responsible # employee_with_job is now configured as responsible of all sub employees below
    assert_equal 4, @employee_with_job.subordinates.size, "employee_with_job should have 4 subordinates (2 into direction_general and 2 in administration)"
  end

  def test_future_leaves
    #TODO
  end

  def test_in_progress_leave_requests
    #TODO
  end

  def test_accepted_leave_requests
    #TODO
  end

  def test_refused_leave_requests
    #TODO
  end

  def test_cancelled_leave_requests
    #TODO
  end

  private

#    def test_with_fixed_duration(duration)
#      leave_duration = duration
#      wanted_leaves_days_left = @leave_days_credit_per_month*12 - leave_duration
#      assert_equal @good_employee.leaves_days_left, wanted_leaves_days_left, "should be equal to #{wanted_leaves_days_left} for one year and with 1 leave of #{duration} days #{@good_employee.leaves.first.duration}"
#    end

    def create_job_responsible(name, service)
      job = Job.new(:name => name, :service_id => service.id, :responsible => true)
      flunk "job should be saved" unless job.save
      job
    end

    def prepare_contextual_variables
      ConfigurationManager.admin_society_identity_configuration_workable_days = "1234560".split("")
      ConfigurationManager.admin_society_identity_configuration_leave_year_start_date = (Date.today - 11.month).strftime("%m/%d")
      return (Date.today - 11.month)
    end
end

