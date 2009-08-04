require 'test_helper'

class LeaveRequestTest < ActiveSupport::TestCase
  fixtures :leave_requests

  def setup
    @step_submit = leave_requests(:step_submit)
    @step_check = leave_requests(:step_check)
    @step_notice = leave_requests(:step_notice)
    @step_close = leave_requests(:step_close)  
  
    @leave_request = LeaveRequest.new
    @leave_request.status = LeaveRequest::STATUS_SUBMITTED
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
    assert @leave_request.errors.invalid?(:employee_id), "employee_id should NOT be valid because it's nil"
    
    @leave_request.employee_id = 0
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:employee_id), "employee_id should be valid"
    assert @leave_request.errors.invalid?(:employee), "employee should NOT be valid because it doesn't exist"
    
    @leave_request.employee_id = employees(:normal).id
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:employee_id), "employee_id should be valid"
    assert !@leave_request.errors.invalid?(:employee), "employee should be valid"
    
    @leave_request.employee = employees(:normal)
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
    
    @leave_request.leave_type_id = 1
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:leave_type_id), "leave_type_id should be valid"
  end
  
  def test_wrong_dates_order
    @step_submit.start_date = @step_submit.end_date + 1
    @step_submit.valid?
    assert !@step_submit.errors.invalid?(:end_date), "end_date should NOT be valid"
  end

  def test_submit_leave_request
    assert @step_submit.submit 
    assert @step_submit.is_status_submitted?
  end
  
  def test_presence_of_responsible_id
    @leave_request.status = LeaveRequest::STATUS_CHECKED
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:responsible_id), "responsible_id should NOT be valid because it's nil"
    
    @leave_request.responsible_id = 0
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:responsible_id), "responsible_id should be valid"
    assert @leave_request.errors.invalid?(:responsible), "responsible should NOT be valid because it doesn't exist"
    
    @leave_request.responsible_id = employees(:normal).id
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:responsible_id), "responsible_id should be valid"
    assert !@leave_request.errors.invalid?(:responsible), "responsible should be valid"
    
    @leave_request.responsible = employees(:normal)
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:responsible_id), "responsible_id should be valid"
    assert !@leave_request.errors.invalid?(:responsible), "responsible should be valid"
  end

  def test_presence_of_checked_at
    @leave_request.status = LeaveRequest::STATUS_CHECKED
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:checked_at), "checked_at should NOT be valid because it's nil"
    
    @leave_request.checked_at = Time.now
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:checked_at), "checked_at should be valid"
  end

  def test_presence_of_responsible_remarks
    @leave_request.status = LeaveRequest::STATUS_CHECKED
    @leave_request.responsible_agreement = false
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:responsible_remarks), "responsible_remarks should NOT be valid because it's nil and the agreement is false"
    
    @leave_request.responsible_remarks = "Lack of employees"
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:responsible_remarks), "responsible_remarks should be valid"
  end

  def test_check_leave_request_with_agreement
    @step_check.checked_at = Time.now
    assert @step_check.check
    assert @step_check.is_status_checked?
  end
  
  def test_check_leave_request_with_refusal
    @step_check.checked_at = Time.now
    @step_check.responsible_agreement = false
    @step_check.responsible_remarks = "Nombre insuffisant d'employés"
    assert @step_check.check
    assert @step_check.is_status_refused_by_responsible?
  end
  
  def test_presence_of_observer_id
    @leave_request.status = LeaveRequest::STATUS_NOTICED
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:observer_id), "observer_id should NOT be valid because it's nil"
    
    @leave_request.observer_id = 0
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:observer_id), "observer_id should be valid"
    assert @leave_request.errors.invalid?(:observer), "observer should NOT be valid because it doesn't exist"
    
    @leave_request.observer_id = employees(:normal).id
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:observer_id), "observer_id should be valid"
    assert !@leave_request.errors.invalid?(:observer), "observer should be valid"
    
    @leave_request.observer = employees(:normal)
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:observer_id), "observer_id should be valid"
    assert !@leave_request.errors.invalid?(:observer), "observer should be valid"
  end

  def test_presence_of_noticed_at
    @leave_request.status = LeaveRequest::STATUS_NOTICED
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:noticed_at), "noticed_at should NOT be valid because it's nil"
    
    @leave_request.noticed_at = Time.now
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:noticed_at), "noticed_at should be valid"
  end

  def test_presence_of_observer_remarks
    @leave_request.status = LeaveRequest::STATUS_NOTICED
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:observer_remarks), "observer_remarks should NOT be valid because it's nil"
    
    @leave_request.observer_remarks = "OK. Note : 4 hours acquired"
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:observer_remarks), "observer_remarks should be valid"
  end

  def test_presence_of_acquired_leaves_days
    @leave_request.status = LeaveRequest::STATUS_NOTICED
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:acquired_leaves_days), "acquired_leaves_days should NOT be valid because it's nil"
    
    @leave_request.acquired_leaves_days = 30
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:acquired_leaves_days), "acquired_leaves_days should be valid"
  end

  def test_notice_leave_request
    @step_notice.checked_at = Time.now - 1
    @step_notice.noticed_at = Time.now
    assert @step_notice.notice
    assert @step_notice.is_status_noticed?
  end
  
  def test_presence_of_director_id
    @leave_request.status = LeaveRequest::STATUS_CLOSED
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:director_id), "director_id should NOT be valid because it's nil"
    
    @leave_request.director_id = 0
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:director_id), "director_id should be valid"
    assert @leave_request.errors.invalid?(:director), "director should NOT be valid because it doesn't exist"
    
    @leave_request.director_id = employees(:normal).id
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:director_id), "director_id should be valid"
    assert !@leave_request.errors.invalid?(:director), "director should be valid"
    
    @leave_request.director = employees(:normal)
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:director_id), "director_id should be valid"
    assert !@leave_request.errors.invalid?(:director), "director should be valid"
  end

  def test_presence_of_ended_at
    @leave_request.status = LeaveRequest::STATUS_CLOSED
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:ended_at), "ended_at should NOT be valid because it's nil"
    
    @leave_request.ended_at = Time.now
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:ended_at), "ended_at should be valid"
  end

  def test_presence_of_director_remarks
    @leave_request.status = LeaveRequest::STATUS_CLOSED
    @leave_request.director_agreement = false
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:director_remarks), "director_remarks should NOT be valid because it's nil and agreement is false"
    
    @leave_request.director_remarks = "No more leaves until the end of the internal crisis"
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:director_remarks), "director_remarks should be valid"
  end

  def test_close_leave_request_with_agreement
    @step_close.checked_at = Time.now - 2
    @step_close.noticed_at = Time.now - 1
    @step_close.ended_at = Time.now
    assert @step_close.close
    assert @step_close.is_status_closed?
  end
  
  def test_close_leave_request_with_refusal
    @step_close.checked_at = Time.now - 2
    @step_close.noticed_at = Time.now - 1
    @step_close.ended_at = Time.now
    @step_close.director_agreement = false
    @step_close.director_remarks = "Pas de nouveau congé avant la fin de la crise interne"
    assert @step_close.close
    assert @step_close.is_status_refused_by_director?
  end

  def test_validate_leave_request
    @step_close.checked_at = Time.now - 2
    @step_close.noticed_at = Time.now - 1
    @step_close.ended_at = Time.now
    @step_close.status = LeaveRequest::STATUS_CLOSED
    assert @step_close.change_status_to_validated
    assert @step_close.is_status_validated?
    
    @step_close.director_agreement = false
    @step_close.director_remarks = "not ok"
    assert !@step_close.change_status_to_validated
  end
    
end
