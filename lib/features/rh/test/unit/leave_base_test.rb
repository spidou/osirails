module LeaveBaseTest
  
  def setup_leaves
    @leave_on_one_day = Leave.new(:start_date    => Date.tomorrow,
                                  :end_date      => Date.tomorrow,
                                  :duration      => 1,
                                  :leave_type_id => @leave_type.id,
                                  :employee_id   => @employee.id)
    
    @leave_on_one_day_and_start_half = Leave.new(:start_date    => Date.tomorrow,
                                                 :end_date      => Date.tomorrow,
                                                 :start_half    => true,
                                                 :duration      => 0.5,
                                                 :leave_type_id => @leave_type.id,
                                                 :employee_id   => @employee.id)
    
    @leave_on_one_day_and_end_half = Leave.new(:start_date    => Date.tomorrow,
                                               :end_date      => Date.tomorrow,
                                               :end_half      => true,
                                               :duration      => 0.5,
                                               :leave_type_id => @leave_type.id,
                                               :employee_id   => @employee.id)
    
    @leave_on_three_days = Leave.new(:start_date    => Date.tomorrow,
                                     :end_date      => Date.tomorrow + 2,
                                     :duration      => 3,
                                     :leave_type_id => @leave_type.id,
                                     :employee_id   => @employee.id)
    
    @leave_on_three_days_and_start_half = Leave.new(:start_date    => Date.tomorrow,
                                                    :end_date      => Date.tomorrow + 2,
                                                    :start_half    => true,
                                                    :duration      => 2.5,
                                                    :leave_type_id => @leave_type.id,
                                                    :employee_id   => @employee.id)
    
    @leave_on_three_days_and_end_half = Leave.new(:start_date    => Date.tomorrow,
                                                  :end_date      => Date.tomorrow + 2,
                                                  :end_half      => true,
                                                  :duration      => 2.5,
                                                  :leave_type_id => @leave_type.id,
                                                  :employee_id   => @employee.id)
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
    @leave.start_half = false
    assert_equal Date.today.to_datetime, @leave.start_datetime, "start_datetime should be equal to #{Date.today.to_datetime} if start_half is false"
    
    @leave.start_half = true
    assert_equal Date.today.to_datetime + 12.hours, @leave.start_datetime, "start_datetime should be equal to #{Date.today.to_datetime + 12.hours} if start_half is true"
  end
  
  def test_end_datetime
    @leave.end_date = Date.today
    @leave.end_half = false
    assert_equal Date.today.to_datetime + 24.hours, @leave.end_datetime, "end_datetime should be equal to #{Date.today.to_datetime + 24.hours} if end_half is false"
    
    @leave.end_half = true
    assert_equal Date.today.to_datetime + 12.hours, @leave.end_datetime, "end_datetime should be equal to #{Date.today.to_datetime + 12.hours} if end_half is true"
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
    ConfigurationManager.admin_society_identity_configuration_workable_days = "0123456".split("")
    @leave.start_date = "2009-4-13".to_date
    @leave.end_date = "2009-4-14".to_date
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
    holidays_size = ConfigurationManager.admin_society_identity_configuration_legal_holidays.size
    expected_duration = @good_leave.calendar_duration - holidays_size
    
    assert_equal expected_duration, @good_leave.total_estimate_duration, "total_estimate_duration should be #{expected_duration} because there's #{holidays_size} legal_holidays within the leave period.\n" +
      "Workable days     : #{ConfigurationManager.admin_society_identity_configuration_workable_days}\n" +
      "Holidays          : #{ConfigurationManager.admin_society_identity_configuration_legal_holidays.inspect}\n" +
      "Start date        : #{@good_leave.start_date}\n" +
      "End date          : #{@good_leave.end_date}\n" +
      "Calendar duration : #{@good_leave.calendar_duration}"
  end
  
  def test_formatted
    #TODO
  end
  
  def test_conflicting_leaves
    #TODO
  end
  
  def test_future_leaves
    #TODO
  end
  
  private
    def total_estimate_duration_test(workable_days)
      ConfigurationManager.admin_society_identity_configuration_workable_days = workable_days
      @leave.start_date = "2009-4-13".to_date
      @leave.end_date = "2009-4-26".to_date
      wanted_duration = workable_days.size*2
      assert_equal wanted_duration, @leave.total_estimate_duration, "total_estimate_duration should be #{wanted_duration} : #{@leave.start_date} to #{@leave.end_date}, workable_days: #{workable_days.inspect} #{ConfigurationManager.admin_society_identity_configuration_workable_days.inspect}"
    end
  
end
