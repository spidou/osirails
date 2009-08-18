require 'test/test_helper'

class LeaveRequestTest < ActiveSupport::TestCase
  fixtures :leave_requests

  def setup
    @employee = employees(:normal)
    @leave_type = leave_types(:good_leave_type)
    
    @step_submit = leave_requests(:step_submit)
    @step_check = leave_requests(:step_check)
    @step_notice = leave_requests(:step_notice)
    @step_close = leave_requests(:step_close) 
      
    @leave_request = LeaveRequest.new({:start_date => Date.today + 19, :end_date => Date.today + 25, :employee => @employee})
    @leave_request.valid?    
  end

  def test_dates_validity_when_step_check
    @step_check.status = LeaveRequest::STATUS_CHECKED
    @step_check.start_date = Date.today - 1
    @step_check.valid?
    assert @step_check.errors.invalid?(:start_date), "start_date should NOT be valid because it has expired"
  end
  
  def test_dates_validity_when_step_notice
    @step_notice.status = LeaveRequest::STATUS_NOTICED
    @step_notice.start_date = Date.today - 1
    @step_notice.valid?
    assert @step_notice.errors.invalid?(:start_date), "start_date should NOT be valid because it has expired"
  end
  
  def test_dates_validity_when_step_close
    @step_close.status = LeaveRequest::STATUS_CLOSED
    @step_close.start_date = Date.today - 1
    @step_close.valid?
    assert @step_close.errors.invalid?(:start_date), "start_date should NOT be valid because it has expired"
  end
  
  def test_presence_of_employee
    @leave_request.employee_id = nil
    @leave_request.valid?
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
    @leave_request.start_date = nil
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:start_date), "start_date should NOT be valid because it's nil"
    
    @leave_request.start_date = Date.today + 26
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:start_date), "start_date should be valid"
  end

  def test_presence_of_end_date
    @leave_request.end_date = nil
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:end_date), "end_date should NOT be valid because it's nil"
    
    @leave_request.end_date = Date.today + 27
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
  
  def test_dates_coherence_order
    @step_submit.start_date = @step_submit.end_date + 1
    @step_submit.valid?
    assert @step_submit.errors.invalid?(:end_date), "end_date should NOT be valid"
  end
  
  def test_dates_coherence_validity
    flunk "start_date should be set at tomorrow" if @step_submit.start_date != Date.tomorrow
    @step_submit.valid?
    assert !@step_submit.errors.invalid?(:start_date), "start_date should be valid"
    
    @step_submit.start_date = Date.today
    @step_submit.valid?
    assert !@step_submit.errors.invalid?(:start_date), "start_date should be valid"
    
    @step_submit.start_date = Date.yesterday
    @step_submit.valid?
    assert @step_submit.errors.invalid?(:start_date), "start_date should NOT be valid because it should be today or after today"
  end
  
  def test_same_dates_and_a_half_max
    flunk "start_half and end_half should be set at true" unless @step_submit.start_half and @step_submit.end_half
    @step_submit.end_date = @step_submit.start_date
    @step_submit.valid?
    assert @step_submit.errors.invalid?(:end_half), "end_half should NOT be valid"
    
    @step_submit.end_half = false
    @step_submit.valid?
    assert !@step_submit.errors.invalid?(:end_half), "end_half should be valid"
  end
  
  def test_unique_dates
    @step_submit.valid?
    assert !@step_submit.errors.invalid?(:start_date), "period should be valid"
    
    @one = LeaveRequest.new({:employee => @employee, :start_date => Date.today + 30, :end_date => Date.today + 30, :start_half => true,  :leave_type => @leave_type})
    @one.valid?
    assert @one.errors.invalid?(:start_date), "period should NOT be valid"
    
    @two = LeaveRequest.new({:start_date => Date.today + 29, :end_date => Date.today + 30, :end_half => true, :employee => @employee})
    @two.valid?
    assert !@two.errors.invalid?(:start_date), "period should be valid"
    
    @three = LeaveRequest.new({:start_date => Date.today + 40, :end_date => Date.today + 40, :end_half => true, :employee => @employee})
    @three.valid?
    assert @three.errors.invalid?(:start_date), "period should NOT be valid"
    
    @four = LeaveRequest.new({:start_date => Date.today + 40, :end_date => Date.today + 41, :start_half => true, :employee => @employee})
    @four.valid?
    assert !@four.errors.invalid?(:start_date), "period should be valid"
  end

  def test_submit_leave_request
    @step_submit.submit
    assert @step_submit.was_submitted?, "leave_request should be submitted"
  end
  
  def test_presence_of_responsible_id
    @step_check.responsible = nil
    
    @step_check.valid?
    assert @step_check.errors.invalid?(:responsible_id), "responsible_id should NOT be valid because it's nil"
    
    @step_check.responsible_id = 0
    @step_check.valid?
    assert !@step_check.errors.invalid?(:responsible_id), "responsible_id should be valid"
    assert @step_check.errors.invalid?(:responsible), "responsible should NOT be valid because it doesn't exist"
    
    @step_check.responsible_id = @employee.id
    @step_check.valid?
    assert !@step_check.errors.invalid?(:responsible_id), "responsible_id should be valid"
    assert !@step_check.errors.invalid?(:responsible), "responsible should be valid"
    
    @step_check.responsible = @employee
    @step_check.valid?
    assert !@step_check.errors.invalid?(:responsible_id), "responsible_id should be valid"
    assert !@step_check.errors.invalid?(:responsible), "responsible should be valid"
  end

  def test_presence_of_checked_at
    @step_check.checked_at = nil
    
    @step_check.valid?
    assert @step_check.errors.invalid?(:checked_at), "checked_at should NOT be valid because it's nil"
    
    @step_check.checked_at = Time.now
    @step_check.valid?
    assert !@step_check.errors.invalid?(:checked_at), "checked_at should be valid"
  end

  def test_presence_of_responsible_remarks
    @step_check.responsible_agreement = false
    @step_check.responsible_remarks = nil
    
    @step_check.valid?
    assert @step_check.errors.invalid?(:responsible_remarks), "responsible_remarks should NOT be valid because it's nil and the agreement is false"
    
    @step_check.responsible_remarks = "Lack of employees"
    @step_check.valid?
    assert !@step_check.errors.invalid?(:responsible_remarks), "responsible_remarks should be valid"
  end

  def test_check_leave_request_with_agreement
    @step_check.check
    assert @step_check.was_checked?, "leave_request should be checked"
  end
  
  def test_check_leave_request_with_refusal
    @step_check.responsible_agreement = false
    @step_check.responsible_remarks = "Nombre insuffisant d'employés"
    @step_check.check

    assert @step_check.was_refused_by_responsible?, "leave_request should be refused by responsible"
  end
  
  def test_presence_of_observer_id
    @step_notice.observer = nil
    
    @step_notice.valid?
    assert @step_notice.errors.invalid?(:observer_id), "observer_id should NOT be valid because it's nil"
    
    @step_notice.observer_id = 0
    @step_notice.valid?
    assert !@step_notice.errors.invalid?(:observer_id), "observer_id should be valid"
    assert @step_notice.errors.invalid?(:observer), "observer should NOT be valid because it doesn't exist"
    
    @step_notice.observer_id = @employee.id
    @step_notice.valid?
    assert !@step_notice.errors.invalid?(:observer_id), "observer_id should be valid"
    assert !@step_notice.errors.invalid?(:observer), "observer should be valid"
    
    @step_notice.observer = @employee
    @step_notice.valid?
    assert !@step_notice.errors.invalid?(:observer_id), "observer_id should be valid"
    assert !@step_notice.errors.invalid?(:observer), "observer should be valid"
  end

  def test_presence_of_noticed_at
    @step_notice.noticed_at = nil
    
    @step_notice.valid?
    assert @step_notice.errors.invalid?(:noticed_at), "noticed_at should NOT be valid because it's nil"
    
    @step_notice.noticed_at = Time.now
    @step_notice.valid?
    assert !@step_notice.errors.invalid?(:noticed_at), "noticed_at should be valid"
  end
  
  def test_presence_of_duration
    @step_notice.duration = nil
    
    @step_notice.valid?
    assert @step_notice.errors.invalid?(:duration), "duration should NOT be valid because it's nil"
    
    @step_notice.duration = 5.0
    @step_notice.valid?
    assert !@step_notice.errors.invalid?(:duration), "duration should be valid"
  end

  def test_presence_of_observer_remarks
    @step_notice.observer_remarks = nil
    
    @step_notice.valid?
    assert @step_notice.errors.invalid?(:observer_remarks), "observer_remarks should NOT be valid because it's nil"
    
    @step_notice.observer_remarks = "OK. Note : 4 hours acquired"
    @step_notice.valid?
    assert !@step_notice.errors.invalid?(:observer_remarks), "observer_remarks should be valid"
  end

  def test_presence_of_acquired_leaves_days
    @step_notice.acquired_leaves_days = nil
    
    @step_notice.valid?
    assert @step_notice.errors.invalid?(:acquired_leaves_days), "acquired_leaves_days should NOT be valid because it's nil"
    
    @step_notice.acquired_leaves_days = 30
    @step_notice.valid?
    assert !@step_notice.errors.invalid?(:acquired_leaves_days), "acquired_leaves_days should be valid"
  end

  def test_notice_leave_request
    @step_notice.notice
    assert @step_notice.was_noticed?, "leave_request should be noticed"
  end
  
  def test_presence_of_director_id
    @step_close.director = nil
    
    @step_close.valid?
    assert @step_close.errors.invalid?(:director_id), "director_id should NOT be valid because it's nil"
    
    @step_close.director_id = 0
    @step_close.valid?
    assert !@step_close.errors.invalid?(:director_id), "director_id should be valid"
    assert @step_close.errors.invalid?(:director), "director should NOT be valid because it doesn't exist"
    
    @step_close.director_id = @employee.id
    @step_close.valid?
    assert !@step_close.errors.invalid?(:director_id), "director_id should be valid"
    assert !@step_close.errors.invalid?(:director), "director should be valid"
    
    @step_close.director = @employee
    @step_close.valid?
    assert !@step_close.errors.invalid?(:director_id), "director_id should be valid"
    assert !@step_close.errors.invalid?(:director), "director should be valid"
  end

  def test_presence_of_ended_at
    @step_close.ended_at = nil
    
    @step_close.valid?
    assert @step_close.errors.invalid?(:ended_at), "ended_at should NOT be valid because it's nil"
    
    @step_close.ended_at = Time.now
    @step_close.valid?
    assert !@step_close.errors.invalid?(:ended_at), "ended_at should be valid"
  end

  def test_presence_of_director_remarks
    @step_close.director_remarks = nil
    @step_close.director_agreement = false
    
    @step_close.valid?
    assert @step_close.errors.invalid?(:director_remarks), "director_remarks should NOT be valid because it's nil and agreement is false"
    
    @step_close.director_remarks = "No more leaves until the end of the internal crisis"
    @step_close.valid?
    assert !@step_close.errors.invalid?(:director_remarks), "director_remarks should be valid"
  end

  def test_close_leave_request_with_agreement
    @step_close.close
    assert @step_close.was_closed?, "leave_request should be closed"
    assert @step_close.leave.is_a?(Leave), "leave_request should genereate a valid leave"
    assert !@step_close.leave.new_record?, "the leave generated should be a new record"
  end
  
  def test_close_leave_request_with_refusal
    @step_close.director_agreement = false
    @step_close.director_remarks = "Pas de nouveau congé avant la fin de la crise interne"
    @step_close.close
    assert @step_close.was_refused_by_director?, "leave_request should be refused by director"
  end
  
  def test_persistent_attributes_when_step_check
    @step_submit.submit
    
    persistent_attributes = ["employee", "start_date", "end_date", "start_half", "end_half", "leave_type_id"]
    
    for element in persistent_attributes
      @step_submit.send("#{element}=",nil)
    end
    
    assert !@step_submit.check, "leave_request should fail at step check"
    
    for element in persistent_attributes
      assert @step_submit.errors.invalid?(element), "#{element} should NOT be valid because it should be persistent"
    end

  end
  
  def test_persistent_attributes_when_step_notice
    @step_check.check 
    
    persistent_attributes = ["employee", "start_date", "end_date", "start_half", "end_half", "leave_type_id", "responsible","checked_at", "responsible_agreement", "responsible_remarks"]
    
    for element in persistent_attributes
      @step_check.send("#{element}=",nil)
    end
        
    assert !@step_check.notice, "leave_request should fail at step notice"
    
    for element in persistent_attributes
      assert @step_check.errors.invalid?(element), "#{element} should NOT be valid because it should be persistent"
    end

  end
  
  def test_persistent_attributes_when_step_close
    @step_notice.notice
    
    persistent_attributes = ["employee", "start_date", "end_date", "start_half", "end_half", "leave_type_id", "responsible","checked_at", "responsible_agreement", "responsible_remarks", "observer", "observer_remarks", "acquired_leaves_days", "duration", "retrieval"]
    
    for element in persistent_attributes
      @step_notice.send("#{element}=",nil)
    end
        
    assert !@step_notice.close, "leave_request should fail at step close"
    
    for element in persistent_attributes
      assert @step_notice.errors.invalid?(element), "#{element} should NOT be valid because it should be persistent"
    end

  end
  
  def test_cancel_at_step_check
    @step_check.cancel
    assert @step_check.cancelled?, "leave_request should be cancelled"
  end
  
  def test_cancel_at_step_notice
    @step_notice.cancel
    assert @step_notice.cancelled?, "leave_request should be cancelled"
  end
  
  def test_cancel_at_step_close
    @step_close.cancel
    assert @step_close.cancelled?, "leave_request should be cancelled"
  end
    
end
