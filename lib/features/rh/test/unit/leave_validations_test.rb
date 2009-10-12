module LeaveValidationsTest
  # in that file, all variables called "leave" can as well refer to a leave or a leave_request
  
  def test_date_consistency
    # when start_date > end_date
    @leave.start_date = Date.today
    @leave.end_date = Date.yesterday
    @leave.valid?
    assert @leave.errors.invalid?(:start_date), "start_date should NOT be valid because it's after end_date"
    assert @leave.errors.invalid?(:end_date), "end_date should NOT be valid because it's before start_date"
    
    # when start_date == end_date
    @leave.end_date = @leave.start_date = Date.today
    @leave.valid?
    assert !@leave.errors.invalid?(:start_date), "start_date should be valid"
    assert !@leave.errors.invalid?(:end_date), "end_date should be valid"
    
    # when start_date < end_date
    @leave.start_date = Date.today
    @leave.end_date = Date.tomorrow
    @leave.valid?
    assert !@leave.errors.invalid?(:start_date), "start_date should be valid"
    assert !@leave.errors.invalid?(:end_date), "end_date should be valid"
  end
  
  def test_same_dates_and_one_half_max
    # when start_half = end_half = true
    @leave.start_date = @leave.end_date = Date.today
    @leave.start_half = @leave.end_half = true
    @leave.valid?
    assert @leave.errors.invalid?(:start_half), "start_half should NOT be valid because both start_half and end_half can't be selected for the same day"
    assert @leave.errors.invalid?(:end_half), "end_half should NOT be valid because both start_half and end_half can't be selected for the same day"
    
    # when start_half = true
    @leave.start_half = true
    @leave.end_half = false
    @leave.valid?
    assert !@leave.errors.invalid?(:start_half), "start_half should be valid"
    assert !@leave.errors.invalid?(:end_half), "end_half should be valid"
    
    # when end_half = true
    @leave.start_half = false
    @leave.end_half = true
    @leave.valid?
    assert !@leave.errors.invalid?(:start_half), "start_half should be valid"
    assert !@leave.errors.invalid?(:end_half), "end_half should be valid"
  end
  
  ### START TEST CONFLICTS WITH LEAVES
  def test_unique_dates_when_there_are_no_conflicting_leave_with_one_day_leave
    check_unique_dates_when_there_are_no_conflicting_leave(@leave, @leave_on_one_day)
  end
  
  def test_unique_dates_when_there_are_no_conflicting_leave_with_several_days_leave
    check_unique_dates_when_there_are_no_conflicting_leave(@leave, @leave_on_three_days)
  end
  
  def test_unique_dates_when_has_existing_leave_on_one_day
    check_unique_dates_when_has_existing_leave_on_one_day(@leave, @leave_on_one_day)
  end
  
  def test_unique_dates_when_has_existing_leave_on_one_day_and_start_half
    check_unique_dates_when_has_existing_leave_on_one_day_and_start_half(@leave, @leave_on_one_day_and_start_half)
  end
  
  def test_unique_dates_when_has_existing_leave_on_one_day_and_end_half
    check_unique_dates_when_has_existing_leave_on_one_day_and_end_half(@leave, @leave_on_one_day_and_end_half)
  end
  
  def test_unique_dates_when_has_existing_leave_on_one_day_and_start_half_with_other_half
    check_unique_dates_when_has_existing_leave_on_one_day_and_half_day_and_new_leave_has_other_half_day(@leave, @leave_on_one_day_and_start_half)
  end
  
  def test_unique_dates_when_has_existing_leave_on_one_day_and_end_half_with_other_half
    check_unique_dates_when_has_existing_leave_on_one_day_and_half_day_and_new_leave_has_other_half_day(@leave, @leave_on_one_day_and_end_half)
  end
  
  def test_unique_dates_when_has_existing_leave_on_several_days
    check_unique_dates_when_has_existing_leave_on_several_days(@leave, @leave_on_three_days)
  end
  
  def test_unique_dates_when_has_existing_leave_on_several_days_and_start_half
    check_unique_dates_when_has_existing_leave_on_several_days_and_start_half(@leave, @leave_on_three_days_and_start_half)
  end
  
  def test_unique_dates_when_has_existing_leave_on_several_days_and_end_half
    check_unique_dates_when_has_existing_leave_on_several_days_and_end_half(@leave, @leave_on_three_days_and_end_half)
  end
  
  def test_unique_dates_when_new_leave_start_date_is_within_an_existing_leave
    check_unique_dates_when_new_leave_start_date_is_within_an_existing_leave(@leave, @leave_on_three_days)
  end
  
  def test_unique_dates_when_new_leave_end_date_is_within_an_existing_leave
    check_unique_dates_when_new_leave_end_date_is_within_an_existing_leave(@leave, @leave_on_three_days)
  end
  
  def test_unique_dates_when_new_leave_start_date_and_end_date_are_within_an_existing_leave
    check_unique_dates_when_new_leave_start_date_and_end_date_are_within_an_existing_leave(@leave, @leave_on_three_days)
  end
  
  def test_unique_dates_when_existing_leave_start_date_and_end_date_are_within_new_leave
    check_unique_dates_when_existing_leave_start_date_and_end_date_are_within_new_leave(@leave, @leave_on_three_days)
  end
  ### END TEST CONFLICTS
  
  private
    ## test when there are no conflicting leave
    #
    #        |               |
    #   start_date        end_date              (new leave)
    #
    def check_unique_dates_when_there_are_no_conflicting_leave(leave, conflicting_leave)
      flunk "conflicting_leave should NOT be saved to perform the following" unless conflicting_leave.new_record?
      # conflicting_leave is not saved in database !
      
      leave.employee    = conflicting_leave.employee
      leave.start_date  = conflicting_leave.start_date
      leave.end_date    = conflicting_leave.end_date
      leave.start_half  = conflicting_leave.start_half
      leave.end_half    = conflicting_leave.end_half
      
      assert_leave_period_is_valid(leave)
    end
    
    ## test when has existing leave on one day
    #
    #       START_DATE      ==      END_DATE     (existing leave)
    #            |                     |
    #            |                     |
    #       start_date      ==      end_date     (new leave)
    #
    def check_unique_dates_when_has_existing_leave_on_one_day(leave, conflicting_leave)
      save_leave(conflicting_leave)
      
      leave.employee    = conflicting_leave.employee
      leave.start_date  = conflicting_leave.start_date
      leave.end_date    = conflicting_leave.end_date
      
      assert_leave_period_is_invalid(leave)
    end
    
    ## test when has existing leave on one day and start_half
    #
    #       START_DATE      ==      END_DATE     (existing leave)
    #            +                     |
    #            +                     |
    #       start_date      ==      end_date     (new leave)
    #
    def check_unique_dates_when_has_existing_leave_on_one_day_and_start_half(leave, conflicting_leave)
      save_leave(conflicting_leave)
      
      leave.employee    = conflicting_leave.employee
      leave.start_date  = conflicting_leave.start_date
      leave.end_date    = conflicting_leave.end_date
      leave.start_half  = conflicting_leave.start_half
      leave.end_half    = conflicting_leave.end_half
      
      assert_leave_period_is_invalid(leave)
    end
    
    ## test when has existing leave on one day and end_half
    #
    #       START_DATE      ==      END_DATE     (existing leave)
    #            |                     +
    #            |                     +
    #       start_date      ==      end_date     (new leave)
    #
    def check_unique_dates_when_has_existing_leave_on_one_day_and_end_half(leave, conflicting_leave)
      save_leave(conflicting_leave)
      
      leave.employee    = conflicting_leave.employee
      leave.start_date  = conflicting_leave.start_date
      leave.end_date    = conflicting_leave.end_date
      leave.start_half  = conflicting_leave.start_half
      leave.end_half    = conflicting_leave.end_half
      
      assert_leave_period_is_invalid(leave)
    end
    
    ## test when has existing leave on one day and half_day but the new leave has the other half day
    #
    #       START_DATE      ==      END_DATE     (existing leave)
    #            +                     |
    #            |                     +
    #       start_date      ==      end_date     (new leave)
    #
    # OR
    #
    #       START_DATE      ==      END_DATE     (existing leave)
    #            |                     +
    #            +                     |
    #       start_date      ==      end_date     (new leave)
    #
    def check_unique_dates_when_has_existing_leave_on_one_day_and_half_day_and_new_leave_has_other_half_day(leave, conflicting_leave)
      save_leave(conflicting_leave)
      
      leave.employee    = conflicting_leave.employee
      leave.start_date  = conflicting_leave.start_date
      leave.end_date    = conflicting_leave.end_date
      leave.start_half  = !conflicting_leave.start_half
      leave.end_half    = !conflicting_leave.end_half
      
      assert_leave_period_is_valid(leave)
    end
    
    ## test when has existing leave on several days
    #
    #       START_DATE      !=      END_DATE     (existing leave)
    #            |                     |
    #            |                     |
    #       start_date      !=      end_date     (new leave)
    #
    def check_unique_dates_when_has_existing_leave_on_several_days(leave, conflicting_leave)
      save_leave(conflicting_leave)
      
      leave.employee    = conflicting_leave.employee
      leave.start_date  = conflicting_leave.start_date
      leave.end_date    = conflicting_leave.end_date
      
      assert_leave_period_is_invalid(leave)
    end
    
    ## test when has existing leave on several days and start_half
    #
    #       START_DATE      !=      END_DATE     (existing leave)
    #            +                     |
    #            +                     |
    #       start_date      !=      end_date     (new leave)
    #
    def check_unique_dates_when_has_existing_leave_on_several_days_and_start_half(leave, conflicting_leave)
      save_leave(conflicting_leave)
      
      leave.employee    = conflicting_leave.employee
      leave.start_date  = conflicting_leave.start_date
      leave.end_date    = conflicting_leave.end_date
      leave.start_half  = conflicting_leave.start_half
      leave.end_half    = conflicting_leave.end_half
      
      assert_leave_period_is_invalid(leave)
    end
    
    ## test when has existing leave on several days and end_half
    #
    #       START_DATE      !=      END_DATE     (existing leave)
    #            |                     +
    #            |                     +
    #       start_date      !=      end_date     (new leave)
    #
    def check_unique_dates_when_has_existing_leave_on_several_days_and_end_half(leave, conflicting_leave)
      save_leave(conflicting_leave)
      
      leave.employee    = conflicting_leave.employee
      leave.start_date  = conflicting_leave.start_date
      leave.end_date    = conflicting_leave.end_date
      leave.start_half  = conflicting_leave.start_half
      leave.end_half    = conflicting_leave.end_half
      
      assert_leave_period_is_invalid(leave)
    end
    
    ## test when new leave start_date is within an existing leave
    #
    #       START_DATE              END_DATE          (existing leave)
    #            |                     |
    #                 |                     |
    #            start_date              end_date     (new leave)
    #
    # OR
    #
    #       START_DATE              END_DATE          (existing leave)
    #            |                     |
    #                 |                |
    #            start_date         end_date          (new leave)
    #
    def check_unique_dates_when_new_leave_start_date_is_within_an_existing_leave(leave, conflicting_leave)
      save_leave(conflicting_leave)
      
      leave.employee    = conflicting_leave.employee
      leave.start_date  = conflicting_leave.start_date + 1.day
      
      # when end_date is after existing leave_request's end_date
      leave.end_date = conflicting_leave.end_date + 1.day
      assert_leave_period_is_invalid(leave)
      
      # when end_date is equal to existing leave_request's end_date
      leave.end_date = conflicting_leave.end_date
      assert_leave_period_is_invalid(leave)
    end
    
    ## test when new leave end_date is within an existing leave
    #
    #       START_DATE              END_DATE          (existing leave)
    #            |                     |
    #       |                     |
    #  start_date              end_date               (new leave)
    #
    # OR
    #
    #       START_DATE              END_DATE          (existing leave)
    #            |                     |
    #            |                |
    #       start_date         end_date               (new leave)
    #
    def check_unique_dates_when_new_leave_end_date_is_within_an_existing_leave(leave, conflicting_leave)
      save_leave(conflicting_leave)
      
      leave.employee  = conflicting_leave.employee
      leave.end_date  = conflicting_leave.end_date - 1.day
      
      # when start_date is before existing leave_request's start_date
      leave.start_date = conflicting_leave.start_date - 1.day
      assert_leave_period_is_invalid(leave)
      
      # when start_date is equal to existing leave_request's start_date
      leave.start_date = conflicting_leave.start_date
      assert_leave_period_is_invalid(leave)
    end
    
    ## test when new leave start_date and end_date are within an existing leave
    #
    #       START_DATE              END_DATE          (existing leave)
    #            |                     |
    #                 |           |
    #            start_date    end_date               (new leave)
    #
    def check_unique_dates_when_new_leave_start_date_and_end_date_are_within_an_existing_leave(leave, conflicting_leave)
      flunk "conflicting_leave.calendar_duration should be greater or equal to 3 days to perform the following, but is actually equal to #{conflicting_leave.calendar_duration}" if conflicting_leave.calendar_duration < 3
      save_leave(conflicting_leave)
      
      leave.employee    = conflicting_leave.employee
      leave.start_date  = conflicting_leave.start_date + 1.day
      leave.end_date    = conflicting_leave.end_date - 1.day
      
      assert_leave_period_is_invalid(leave)
    end
    
    ## test when an existing leave start_date and end_date are within the new leave
    #
    #       START_DATE              END_DATE          (existing leave)
    #            |                     |
    #       |                               |
    #  start_date                        end_date     (new leave)
    #
    def check_unique_dates_when_existing_leave_start_date_and_end_date_are_within_new_leave(leave, conflicting_leave)
      save_leave(conflicting_leave)
      
      leave.employee    = conflicting_leave.employee
      leave.start_date  = conflicting_leave.start_date - 1.day
      leave.end_date    = conflicting_leave.end_date + 1.day
      
      assert_leave_period_is_invalid(leave)
    end
    
    def save_leave(leave)
      if leave.is_a?(Leave)
        result = leave.save!
      elsif leave.is_a?(LeaveRequest)
        result = leave.submit
      end
      flunk "conflicting_leave should be saved to perform the following" unless result
      leave.reload
    end
    
    def assert_leave_period_is_invalid(leave)
      leave.valid?
      assert leave.errors.invalid?(:base), "#{leave.class.name} base should NOT be valid because another leave exists at the given date"
      assert leave.errors.invalid?(:start_date), "#{leave.class.name} start_date should NOT be valid because another leave exists at the given date"
      assert leave.errors.invalid?(:end_date), "#{leave.class.name} end_date should NOT be valid because another leave exists at the given date"
    end
    
    def assert_leave_period_is_valid(leave)
      leave.valid?
      assert !leave.errors.invalid?(:start_date), "#{leave.class.name} start_date should be valid"
      assert !leave.errors.invalid?(:end_date), "#{leave.class.name} start_date should be valid"
    end
end
