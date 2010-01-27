require 'test/test_helper'
require File.dirname(__FILE__) + '/leave_base_test'
require File.dirname(__FILE__) + '/leave_validations_test'

class LeaveRequestTest < ActiveSupport::TestCase
  include LeaveBaseTest
  include LeaveValidationsTest
  
  def setup         
    @employee = employees(:trish_doe)
    @superior = employees(:johnny)
    @leave_type = leave_types(:good_leave_type)
    
    flunk "@employee should be valid to perform the following tests" unless @employee.valid?
    flunk "@superior should be valid to perform the following tests" unless @superior.valid?
    flunk "@leave_type should be valid to perform the following tests" unless @leave_type.valid?
    
    @leave_request_on_one_day = LeaveRequest.new(:start_date    => Date.tomorrow,
                                                 :end_date      => Date.tomorrow,
                                                 :leave_type_id => @leave_type.id,
                                                 :employee_id   => @employee.id)
    
    @leave_request_on_one_day_and_start_half = LeaveRequest.new(:start_date    => Date.tomorrow,
                                                                :end_date      => Date.tomorrow,
                                                                :start_half    => true,
                                                                :leave_type_id => @leave_type.id,
                                                                :employee_id   => @employee.id)
    
    @leave_request_on_one_day_and_end_half = LeaveRequest.new(:start_date    => Date.tomorrow,
                                                              :end_date      => Date.tomorrow,
                                                              :end_half      => true,
                                                              :leave_type_id => @leave_type.id,
                                                              :employee_id   => @employee.id)
    
    @leave_request_on_three_days = LeaveRequest.new(:start_date    => Date.tomorrow,
                                                    :end_date      => Date.tomorrow + 2,
                                                    :leave_type_id => @leave_type.id,
                                                    :employee_id   => @employee.id)
    
    @leave_request_on_three_days_and_start_half = LeaveRequest.new(:start_date    => Date.tomorrow,
                                                                   :end_date      => Date.tomorrow + 2,
                                                                   :start_half    => true,
                                                                   :leave_type_id => @leave_type.id,
                                                                   :employee_id   => @employee.id)
    
    @leave_request_on_three_days_and_end_half = LeaveRequest.new(:start_date    => Date.tomorrow,
                                                                 :end_date      => Date.tomorrow + 2,
                                                                 :end_half      => true,
                                                                 :leave_type_id => @leave_type.id,
                                                                 :employee_id   => @employee.id)
    
    @leave = @leave_request = LeaveRequest.new # @leave is used in leave_base_test and leave_validations_test
    @leave_request.valid?
    @leave.valid?
    
    # @good_leave is used in leave_base_test and leave_validations_test
    @good_leave = LeaveRequest.new(:start_date     => Date.today.next_month.next_month.monday,
                                   :end_date       => Date.today.next_month.next_month.monday + 6.days,
                                   :start_half     => true,
                                   :end_half       => true,
                                   :employee_id    => @employee.id,
                                   :leave_type_id  => @leave_type.id)
    flunk "good_leave should be submitted to perform the following #{@good_leave.errors.inspect}" unless @good_leave.submit
    
    setup_leaves
  end
  
  def teardown
    @leave_request = nil
    @employee = nil
    @superior = nil
    @leave_type = nil
    @good_leave = nil
  end
  
  def test_start_date_validity_at_creation
    @leave_request.start_date = Date.today
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:start_date), "start_date should be valid"
    
    @leave_request.start_date = Date.yesterday
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:start_date), "start_date should NOT be valid because it is before today"
  end

  def test_start_date_validity_when_step_check
    prepare_to_check(@leave_request,true)
    
    @leave_request.start_date = Date.today
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:start_date), "start_date should be valid"
    
    @leave_request.start_date = Date.yesterday
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:start_date), "start_date should NOT be valid because it is before today"
  end
  
  def test_start_date_validity_when_step_notice
    prepare_to_check(@leave_request,true)
    prepare_to_notice(@leave_request)
    
    @leave_request.start_date = Date.today
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:start_date), "start_date should be valid"
    
    @leave_request.start_date = Date.yesterday
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:start_date), "start_date should NOT be valid because it is before today"
  end 
  
  def test_start_date_validity_when_step_close
    prepare_to_check(@leave_request,true)
    prepare_to_notice(@leave_request)
    prepare_to_close(@leave_request,true)
    
    @leave_request.start_date = Date.today
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:start_date), "start_date should be valid"
    
    @leave_request.start_date = Date.yesterday
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:start_date), "start_date should NOT be valid because it is before today"
  end 
  
  def test_presence_of_employee
    assert @leave_request.errors.invalid?(:employee_id), "employee_id should NOT be valid because it's nil"
    
    @leave_request.employee_id = 0
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:employee_id), "employee_id should be valid"
    
    @leave_request.employee_id = @employee.id
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:employee_id), "employee_id should be valid"
    assert !@leave_request.errors.invalid?(:employee), "employee should be valid"
    
    @leave_request.employee = @employee
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:employee_id), "employee_id should be valid"
    assert !@leave_request.errors.invalid?(:employee), "employee should be valid"
  end
  
  def test_presence_of_start_date
    assert @leave_request.errors.invalid?(:start_date), "start_date should NOT be valid because it's nil"
    
    @leave_request.start_date = Date.today
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:start_date), "start_date should be valid"
  end

  def test_presence_of_end_date
    assert @leave_request.errors.invalid?(:end_date), "end_date should NOT be valid because it's nil"
    
    @leave_request.end_date = Date.today
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:end_date), "end_date should be valid"
  end

  def test_presence_of_leave_type_id
    assert @leave_request.errors.invalid?(:leave_type_id), "leave_type_id should NOT be valid because it's nil"
    
    @leave_request.leave_type_id = 0
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:leave_type_id), "leave_type_id should be valid"
    assert @leave_request.errors.invalid?(:leave_type), "leave_type should NOT be valid because it doesn't exist"
    
    @leave_request.leave_type_id = @leave_type.id
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:leave_type_id), "leave_type_id should be valid"
    assert !@leave_request.errors.invalid?(:leave_type), "leave_type should be valid"
    
    @leave_request.leave_type = @leave_type
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:leave_type_id), "leave_type_id should be valid"
    assert !@leave_request.errors.invalid?(:leave_type), "leave_type should be valid"
  end
  
  def test_validity_of_status
    good_values = [ LeaveRequest::STATUS_CANCELLED, LeaveRequest::STATUS_SUBMITTED, LeaveRequest::STATUS_CHECKED,
                    LeaveRequest::STATUS_REFUSED_BY_RESPONSIBLE, LeaveRequest::STATUS_NOTICED,
                    LeaveRequest::STATUS_CLOSED, LeaveRequest::STATUS_REFUSED_BY_DIRECTOR ]
    good_values.each do |value|
      @leave_request.status = value
      @leave_request.valid?
      assert !@leave_request.errors.invalid?(:status), "status should be valid for that value : #{value}"
    end
    
    bad_values = [nil, -1, -3, 5, 6, 10]
    bad_values.each do |value|
      @leave_request.status = value
      @leave_request.valid?
      assert @leave_request.errors.invalid?(:status), "status should NOT be valid for that value : #{value}"
    end
  end
  
  ### START TEST CONFLICTS WITH LEAVE REQUESTS
  def test_unique_dates_when_there_are_no_conflicting_leave_request_with_one_day_leave_request
    check_unique_dates_when_there_are_no_conflicting_leave(@leave, @leave_request_on_one_day)
  end
  
  def test_unique_dates_when_there_are_no_conflicting_leave_request_with_several_days_leave_request
    check_unique_dates_when_there_are_no_conflicting_leave(@leave, @leave_request_on_three_days)
  end
  
  def test_unique_dates_when_has_existing_leave_request_on_one_day
    check_unique_dates_when_has_existing_leave_on_one_day(@leave_request, @leave_request_on_one_day)
  end
  
  def test_unique_dates_when_has_existing_leave_request_on_one_day_and_start_half
    check_unique_dates_when_has_existing_leave_on_one_day_and_start_half(@leave_request, @leave_request_on_one_day_and_start_half)
  end
  
  def test_unique_dates_when_has_existing_leave_request_on_one_day_and_end_half
    check_unique_dates_when_has_existing_leave_on_one_day_and_end_half(@leave_request, @leave_request_on_one_day_and_end_half)
  end
  
  def test_unique_dates_when_has_existing_leave_request_on_one_day_and_start_half_with_other_half
    check_unique_dates_when_has_existing_leave_on_one_day_and_half_day_and_new_leave_has_other_half_day(@leave, @leave_request_on_one_day_and_start_half)
  end
  
  def test_unique_dates_when_has_existing_leave_request_on_one_day_and_end_half_with_other_half
    check_unique_dates_when_has_existing_leave_on_one_day_and_half_day_and_new_leave_has_other_half_day(@leave, @leave_request_on_one_day_and_end_half)
  end
  
  def test_unique_dates_when_has_existing_leave_request_on_several_days
    check_unique_dates_when_has_existing_leave_on_several_days(@leave_request, @leave_request_on_three_days)
  end
  
  def test_unique_dates_when_has_existing_leave_request_on_several_days_and_start_half
    check_unique_dates_when_has_existing_leave_on_several_days_and_start_half(@leave_request, @leave_request_on_three_days_and_start_half)
  end
  
  def test_unique_dates_when_has_existing_leave_request_on_several_days_and_end_half
    check_unique_dates_when_has_existing_leave_on_several_days_and_end_half(@leave_request, @leave_request_on_three_days_and_end_half)
  end
  
  def test_unique_dates_when_new_leave_request_start_date_is_within_an_existing_leave_request
    check_unique_dates_when_new_leave_start_date_is_within_an_existing_leave(@leave_request, @leave_request_on_three_days)
  end
  
  def test_unique_dates_when_new_leave_request_end_date_is_within_an_existing_leave_request
    check_unique_dates_when_new_leave_end_date_is_within_an_existing_leave(@leave_request, @leave_request_on_three_days)
  end
  
  def test_unique_dates_when_new_leave_request_start_date_and_end_date_are_within_an_existing_leave_request
    check_unique_dates_when_new_leave_start_date_and_end_date_are_within_an_existing_leave(@leave_request, @leave_request_on_three_days)
  end
  
  def test_unique_dates_when_existing_leave_request_start_date_and_end_date_are_within_new_leave_request
    check_unique_dates_when_existing_leave_start_date_and_end_date_are_within_new_leave(@leave_request, @leave_request_on_three_days)
  end
  ### END TEST CONFLICTS
  
  def test_submit_leave_request
    prepare_to_submit(@leave_request)
    @leave_request.submit
    assert @leave_request.was_submitted?, "leave_request should be submitted"
  end
  
  def test_presence_of_responsible_id
    prepare_to_submit(@leave_request)
    @leave_request.submit
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:responsible_id), "responsible_id should NOT be valid because it's nil"
    
    @leave_request.responsible_id = 0
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:responsible_id), "responsible_id should be valid"
    assert @leave_request.errors.invalid?(:responsible), "responsible should NOT be valid because it doesn't exist"
    
    @leave_request.responsible_id = @employee.id
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:responsible_id), "responsible_id should be valid"
    assert !@leave_request.errors.invalid?(:responsible), "responsible should be valid"
    
    @leave_request.responsible = @employee
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:responsible_id), "responsible_id should be valid"
    assert !@leave_request.errors.invalid?(:responsible), "responsible should be valid"
  end

  def test_presence_of_checked_at
    prepare_to_submit(@leave_request)
    @leave_request.submit
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:checked_at), "checked_at should NOT be valid because it's nil"
    
    @leave_request.checked_at = Time.now
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:checked_at), "checked_at should be valid"
  end

  def test_presence_of_responsible_remarks
    prepare_to_submit(@leave_request)
    flunk "@leave_request should submit with success to perform the following test" unless @leave_request.submit
    
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:responsible_remarks), "responsible_remarks should NOT be valid because it's nil and the agreement is not true"
    
    @leave_request.responsible_agreement = true
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:responsible_remarks), "responsible_remarks should be valid"
    
    @leave_request.responsible_agreement = false
    @leave_request.responsible_remarks = "Lack of employees"
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:responsible_remarks), "responsible_remarks should be valid"
  end

  def test_check_leave_request_with_agreement
    prepare_to_submit(@leave_request)
    flunk "@leave_request should submit with success to perform the following test" unless @leave_request.submit
    prepare_to_check(@leave_request,true)
    @leave_request.check
    assert @leave_request.was_checked?, "leave_request should be checked"
  end
  
  def test_check_leave_request_with_refusal
    prepare_to_submit(@leave_request)
    flunk "@leave_request should submit with success to perform the following test" unless @leave_request.submit
    prepare_to_check(@leave_request,false)
    @leave_request.check
    assert @leave_request.was_refused_by_responsible?, "leave_request should be refused by responsible"
  end
  
  def test_presence_of_observer_id
    prepare_to_submit(@leave_request)
    @leave_request.submit
    prepare_to_check(@leave_request,true)
    @leave_request.check
    
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:observer_id), "observer_id should NOT be valid because it's nil"
    
    @leave_request.observer_id = 0
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:observer_id), "observer_id should be valid"
    assert @leave_request.errors.invalid?(:observer), "observer should NOT be valid because it doesn't exist"
    
    @leave_request.observer_id = @employee.id
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:observer_id), "observer_id should be valid"
    assert !@leave_request.errors.invalid?(:observer), "observer should be valid"
    
    @leave_request.observer = @employee
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:observer_id), "observer_id should be valid"
    assert !@leave_request.errors.invalid?(:observer), "observer should be valid"
  end

  def test_presence_of_noticed_at
    prepare_to_submit(@leave_request)
    @leave_request.submit
    prepare_to_check(@leave_request,true)
    @leave_request.check
    
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:noticed_at), "noticed_at should NOT be valid because it's nil"
    
    @leave_request.noticed_at = Time.now
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:noticed_at), "noticed_at should be valid"
  end
  
  def test_presence_of_duration
    prepare_to_submit(@leave_request)
    @leave_request.submit
    prepare_to_check(@leave_request,true)
    @leave_request.check
    
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:duration), "duration should NOT be valid because it's nil"
    
    @leave_request.duration = 5.0
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:duration), "duration should be valid"
  end

  def test_presence_of_observer_remarks
    prepare_to_submit(@leave_request)
    @leave_request.submit
    prepare_to_check(@leave_request,true)
    @leave_request.check
    
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:observer_remarks), "observer_remarks should NOT be valid because it's nil"
    
    @leave_request.observer_remarks = "OK. Note : 4 hours acquired"
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:observer_remarks), "observer_remarks should be valid"
  end

  def test_presence_of_acquired_leaves_days
    prepare_to_submit(@leave_request)
    @leave_request.submit
    prepare_to_check(@leave_request,true)
    @leave_request.check
    
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:acquired_leaves_days), "acquired_leaves_days should NOT be valid because it's nil"
    
    @leave_request.acquired_leaves_days = 30
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:acquired_leaves_days), "acquired_leaves_days should be valid"
  end

  def test_notice_leave_request
    prepare_to_submit(@leave_request)
    flunk "@leave_request should submit with success to perform the following test" unless @leave_request.submit
    prepare_to_check(@leave_request,true)
    flunk "@leave_request should check with success to perform the following test" unless @leave_request.check
    prepare_to_notice(@leave_request)
    @leave_request.notice
    assert @leave_request.was_noticed?, "leave_request should be noticed"
  end  
  
  def test_presence_of_director_id
    prepare_to_submit(@leave_request)
    flunk "@leave_request should submit with success to perform the following test" unless @leave_request.submit
    prepare_to_check(@leave_request,true)
    flunk "@leave_request should check with success to perform the following test" unless @leave_request.check
    prepare_to_notice(@leave_request)
    flunk "@leave_request should notice with success to perform the following test" unless @leave_request.notice
    
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:director_id), "director_id should NOT be valid because it's nil"
    
    @leave_request.director_id = 0
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:director_id), "director_id should be valid"
    assert @leave_request.errors.invalid?(:director), "director should NOT be valid because it doesn't exist"
    
    @leave_request.director_id = @employee.id
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:director_id), "director_id should be valid"
    assert !@leave_request.errors.invalid?(:director), "director should be valid"
    
    @leave_request.director = @employee
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:director_id), "director_id should be valid"
    assert !@leave_request.errors.invalid?(:director), "director should be valid"
  end

  def test_presence_of_ended_at
    prepare_to_submit(@leave_request)
    flunk "@leave_request should submit with success to perform the following test" unless @leave_request.submit
    prepare_to_check(@leave_request,true)
    flunk "@leave_request should check with success to perform the following test" unless @leave_request.check
    prepare_to_notice(@leave_request)
    flunk "@leave_request should notice with success to perform the following test" unless @leave_request.notice
    
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:ended_at), "ended_at should NOT be valid because it's nil"
    
    @leave_request.ended_at = Time.now
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:ended_at), "ended_at should be valid"
  end

  def test_presence_of_director_remarks
    prepare_to_submit(@leave_request)
    flunk "@leave_request should submit with success to perform the following test" unless @leave_request.submit
    prepare_to_check(@leave_request,true)
    flunk "@leave_request should check with success to perform the following test" unless @leave_request.check
    prepare_to_notice(@leave_request)
    flunk "@leave_request should notice with success to perform the following test" unless @leave_request.notice
    
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:director_remarks), "director_remarks should NOT be valid because it's nil and agreement is false"
    
    @leave_request.director_agreement = true
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:director_remarks), "director_remarks should be valid"
    
    @leave_request.director_agreement = false
    @leave_request.director_remarks = "No more leaves until the end of the internal crisis"
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:director_remarks), "director_remarks should be valid"
  end

  def test_close_leave_request_with_agreement
    prepare_to_submit(@leave_request)
    flunk "@leave_request should submit with success to perform the following test" unless @leave_request.submit
    prepare_to_check(@leave_request,true)
    flunk "@leave_request should check with success to perform the following test" unless @leave_request.check
    prepare_to_notice(@leave_request)
    flunk "@leave_request should notice with success to perform the following test" unless @leave_request.notice
    prepare_to_close(@leave_request,true)
    @leave_request.close
    assert @leave_request.was_closed?, "leave_request should be closed"
    assert @leave_request.leave.is_a?(Leave), "leave_request should genereate a valid leave"
    assert !@leave_request.leave.new_record?, "the leave generated should be a new record"
  end
  
  def test_close_leave_request_with_refusal
    prepare_to_submit(@leave_request)
    flunk "@leave_request should submit with success to perform the following test" unless @leave_request.submit
    prepare_to_check(@leave_request,true)
    flunk "@leave_request should check with success to perform the following test" unless @leave_request.check
    prepare_to_notice(@leave_request)
    flunk "@leave_request should notice with success to perform the following test" unless @leave_request.notice
    prepare_to_close(@leave_request,false)
    @leave_request.close
    assert @leave_request.was_refused_by_director?, "leave_request should be refused by director"
  end
  
  def test_persistent_attributes_when_submitted
    prepare_to_submit(@leave_request)
    flunk "@leave_request should submit with success to perform the following test" unless @leave_request.submit
    
    persistent_attributes = ["employee_id", "start_date", "end_date", "start_half", "end_half", "leave_type_id"]
    
    for element in persistent_attributes
      @leave_request.send("#{element}=",nil)
    end
    
    assert !@leave_request.check, "leave_request should fail at step check"
    
    for element in persistent_attributes
      assert @leave_request.errors.invalid?(element), "#{element} should NOT be valid because it should be persistent"
    end
  end
  
  def test_persistent_attributes_when_refused_by_responsible
    prepare_to_submit(@leave_request)
    flunk "@leave_request should submit with success to perform the following test" unless @leave_request.submit
    prepare_to_check(@leave_request,false)
    flunk "@leave_request should check with success to perform the following test" unless @leave_request.check
    
    persistent_attributes = ["employee_id", "start_date", "end_date", "start_half", "end_half", "leave_type_id"]
    
    for element in persistent_attributes
      @leave_request.send("#{element}=",nil)
    end
    
    assert !@leave_request.check, "leave_request should fail at step check"
    
    for element in persistent_attributes
      assert @leave_request.errors.invalid?(element), "#{element} should NOT be valid because it should be persistent"
    end
  end
  
  def test_persistent_attributes_when_checked
    prepare_to_submit(@leave_request)
    flunk "@leave_request should submit with success to perform the following test" unless @leave_request.submit
    prepare_to_check(@leave_request,true)
    flunk "@leave_request should check with success to perform the following test" unless @leave_request.check
    
    persistent_attributes = ["employee_id", "start_date", "end_date", "start_half", "end_half", "leave_type_id", "responsible_id","checked_at", "responsible_agreement", "responsible_remarks"]
    
    for element in persistent_attributes
      @leave_request.send("#{element}=",nil)
    end
        
    assert !@leave_request.notice, "leave_request should fail at step notice"
    
    for element in persistent_attributes
      assert @leave_request.errors.invalid?(element), "#{element} should NOT be valid because it should be persistent"
    end

  end
  
  def test_persistent_attributes_when_noticed
    prepare_to_submit(@leave_request)
    flunk "@leave_request should submit with success to perform the following test" unless @leave_request.submit
    prepare_to_check(@leave_request,true)
    flunk "@leave_request should check with success to perform the following test" unless @leave_request.check
    prepare_to_notice(@leave_request)
    flunk "@leave_request should notice with success to perform the following test" unless @leave_request.notice
    
    persistent_attributes = ["employee_id", "start_date", "end_date", "start_half", "end_half", "leave_type_id", "responsible_id","checked_at", "responsible_agreement", "responsible_remarks", "observer_id", "observer_remarks", "acquired_leaves_days", "duration"]
    
    for element in persistent_attributes
      @leave_request.send("#{element}=",nil)
    end
        
    assert !@leave_request.close, "leave_request should fail at step close"
    
    for element in persistent_attributes
      assert @leave_request.errors.invalid?(element), "#{element} should NOT be valid because it should be persistent"
    end

  end
  
  def test_persistent_attributes_when_refused_by_director
    prepare_to_submit(@leave_request)
    flunk "@leave_request should submit with success to perform the following test" unless @leave_request.submit
    prepare_to_check(@leave_request,true)
    flunk "@leave_request should check with success to perform the following test" unless @leave_request.check
    prepare_to_notice(@leave_request)
    flunk "@leave_request should notice with success to perform the following test" unless @leave_request.notice
    prepare_to_close(@leave_request,false)
    flunk "@leave_request should close with success to perform the following test" unless @leave_request.close
    
    persistent_attributes = ["employee_id", "start_date", "end_date", "start_half", "end_half", "leave_type_id", "responsible_id","checked_at", "responsible_agreement", "responsible_remarks", "observer_id", "observer_remarks", "acquired_leaves_days", "duration"]
    
    for element in persistent_attributes
      @leave_request.send("#{element}=",nil)
    end
        
    assert !@leave_request.close, "leave_request should fail at step close"
    
    for element in persistent_attributes
      assert @leave_request.errors.invalid?(element), "#{element} should NOT be valid because it should be persistent"
    end

  end
  
  def test_cancel_when_submitted
    prepare_to_submit(@leave_request)
    flunk "@leave_request should submit with success to perform the following test" unless @leave_request.submit
  
    @leave_request.cancel
    assert @leave_request.cancelled?, "leave_request should be cancelled"
  end
  
  def test_cancel_when_refused_by_responsible
    prepare_to_submit(@leave_request)
    flunk "@leave_request should submit with success to perform the following test" unless @leave_request.submit
    prepare_to_check(@leave_request,false)
    flunk "@leave_request should check with success to perform the following test" unless @leave_request.check
    
    @leave_request.cancel
    assert @leave_request.cancelled?, "leave_request should be cancelled"
  end
  
  def test_cancel_when_checked
    prepare_to_submit(@leave_request)
    flunk "@leave_request should submit with success to perform the following test" unless @leave_request.submit
    prepare_to_check(@leave_request,true)
    flunk "@leave_request should check with success to perform the following test" unless @leave_request.check
    
    @leave_request.cancel
    assert @leave_request.cancelled?, "leave_request should be cancelled"
  end
  
  def test_cancel_when_closed
    prepare_to_submit(@leave_request)
    flunk "@leave_request should submit with success to perform the following test" unless @leave_request.submit
    prepare_to_check(@leave_request,true)
    flunk "@leave_request should check with success to perform the following test" unless @leave_request.check
    prepare_to_notice(@leave_request)
    flunk "@leave_request should notice with success to perform the following test" unless @leave_request.notice
  
    @leave_request.cancel
    assert @leave_request.cancelled?, "leave_request should be cancelled"
  end
  
  def test_cancel_when_refused_by_director
    prepare_to_submit(@leave_request)
    flunk "@leave_request should submit with success to perform the following test" unless @leave_request.submit
    prepare_to_check(@leave_request,true)
    flunk "@leave_request should check with success to perform the following test" unless @leave_request.check
    prepare_to_notice(@leave_request)
    flunk "@leave_request should notice with success to perform the following test" unless @leave_request.notice
    prepare_to_close(@leave_request,false)
    flunk "@leave_request should close with success to perform the following test" unless @leave_request.close
  
    @leave_request.cancel
    assert @leave_request.cancelled?, "leave_request should be cancelled"
  end
  
  def test_leave_requests_to_notice #named_scope
    #TODO
  end
  
  def test_leave_requests_to_close #named_scope
    #TODO
  end
  
  private
  
    def prepare_to_submit(leave_request)
      leave_request.employee = @employee
      leave_request.start_date = Date.today
      leave_request.end_date = Date.today + 1
      leave_request.leave_type = @leave_type
      leave_request.start_half = true
      leave_request.end_half = true
      leave_request.comment = "congé de formation"
    end
    
    def prepare_to_check(leave_request,agreement)
      leave_request.status = LeaveRequest::STATUS_SUBMITTED
      leave_request.responsible = @superior
      leave_request.responsible_agreement = true if agreement
      leave_request.responsible_remarks = agreement ? "RAS" : "Manque d'effectif"
    end
    
    def prepare_to_notice(leave_request)
      leave_request.status = LeaveRequest::STATUS_CHECKED
      leave_request.observer = @superior
      leave_request.acquired_leaves_days = 15
      leave_request.observer_remarks = "RAS"
      leave_request.duration = 1
    end
    
    def prepare_to_close(leave_request,agreement)
      leave_request.status = LeaveRequest::STATUS_NOTICED
      leave_request.director = @superior
      leave_request.director_agreement = true if agreement
      leave_request.director_remarks = "Pas de congé ce mois-ci" unless agreement
    end
    
end
