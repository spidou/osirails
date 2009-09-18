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
  
  def test_total_estimate_duration
    #TODO move tests from leave_test to here
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
  
end
