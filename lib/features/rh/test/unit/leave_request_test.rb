require 'test_helper'

class LeaveRequestTest < ActiveSupport::TestCase
  fixtures :leave_requests

  def setup
    @step_submit = leave_requests(:step_submit)
    @step_check = leave_requests(:step_check)
    @step_notice = leave_requests(:step_notice)
    @step_close = leave_requests(:step_close)  
  
    @leave_request = LeaveRequest.new
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
  
  def test_dates_coherence_order
    @step_submit.start_date = @step_submit.end_date + 1
    @step_submit.valid?
    assert @step_submit.errors.invalid?(:end_date), "end_date should NOT be valid"
  end
  
  def test_dates_coherence_validity
    @step_submit.start_date = Date.today - 1
    @step_submit.valid?
    assert @step_submit.errors.invalid?(:start_date), "start_date should NOT be valid"
  end
  
  def test_same_dates_and_a_half_max
    @step_submit.end_date = @step_submit.start_date
    @step_submit.valid?
    assert @step_submit.errors.invalid?(:end_half), "end_half should NOT be valid"
  end

  def test_submit_leave_request
    assert @step_submit.submit 
    assert @step_submit.was_submitted?
  end
  
  def test_presence_of_responsible_id
    @step_check.responsible = nil
    
    @step_check.valid?
    assert @step_check.errors.invalid?(:responsible_id), "responsible_id should NOT be valid because it's nil"
    
    @step_check.responsible_id = 0
    @step_check.valid?
    assert !@step_check.errors.invalid?(:responsible_id), "responsible_id should be valid"
    assert @step_check.errors.invalid?(:responsible), "responsible should NOT be valid because it doesn't exist"
    
    @step_check.responsible_id = employees(:normal).id
    @step_check.valid?
    assert !@step_check.errors.invalid?(:responsible_id), "responsible_id should be valid"
    assert !@step_check.errors.invalid?(:responsible), "responsible should be valid"
    
    @step_check.responsible = employees(:normal)
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
    assert @step_check.check
    @step_check.save
    assert @step_check.was_checked?
  end
  
  def test_check_leave_request_with_refusal
    @step_check.responsible_agreement = false
    @step_check.responsible_remarks = "Nombre insuffisant d'employés"
    assert @step_check.check
    @step_check.save
    assert @step_check.was_refused_by_responsible?
  end
  
  def test_presence_of_observer_id
    @step_notice.observer = nil
    
    @step_notice.valid?
    assert @step_notice.errors.invalid?(:observer_id), "observer_id should NOT be valid because it's nil"
    
    @step_notice.observer_id = 0
    @step_notice.valid?
    assert !@step_notice.errors.invalid?(:observer_id), "observer_id should be valid"
    assert @step_notice.errors.invalid?(:observer), "observer should NOT be valid because it doesn't exist"
    
    @step_notice.observer_id = employees(:normal).id
    @step_notice.valid?
    assert !@step_notice.errors.invalid?(:observer_id), "observer_id should be valid"
    assert !@step_notice.errors.invalid?(:observer), "observer should be valid"
    
    @step_notice.observer = employees(:normal)
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
    assert @step_notice.notice
    @step_notice.save
    assert @step_notice.was_noticed?
  end
  
  def test_presence_of_director_id
    @step_close.director = nil
    
    @step_close.valid?
    assert @step_close.errors.invalid?(:director_id), "director_id should NOT be valid because it's nil"
    
    @step_close.director_id = 0
    @step_close.valid?
    assert !@step_close.errors.invalid?(:director_id), "director_id should be valid"
    assert @step_close.errors.invalid?(:director), "director should NOT be valid because it doesn't exist"
    
    @step_close.director_id = employees(:normal).id
    @step_close.valid?
    assert !@step_close.errors.invalid?(:director_id), "director_id should be valid"
    assert !@step_close.errors.invalid?(:director), "director should be valid"
    
    @step_close.director = employees(:normal)
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
    assert @step_close.close
    @step_close.save
    assert @step_close.was_closed?
  end
  
  def test_close_leave_request_with_refusal
    @step_close.director_agreement = false
    @step_close.director_remarks = "Pas de nouveau congé avant la fin de la crise interne"
    assert @step_close.close
    @step_close.save
    assert @step_close.was_refused_by_director?
  end
  
  def test_persistent_attributes_when_step_check
    @step_submit.submit
    
    persistent_attributes = ["employee", "start_date", "end_date", "start_half", "end_half", "leave_type_id"]
    
    for element in persistent_attributes
      @step_submit.send("#{element}=",nil)
    end
    
    @step_submit.check
    !@step_submit.save
    
    for element in persistent_attributes
    assert @step_submit.errors.invalid?(element), "#{element} should have changed"
    end

  end
  
  def test_persistent_attributes_when_step_notice
    @step_check.check 
    
    persistent_attributes = ["employee", "start_date", "end_date", "start_half", "end_half", "leave_type_id", "responsible","checked_at", "responsible_agreement", "responsible_remarks"]
    
    for element in persistent_attributes
      @step_check.send("#{element}=",nil)
    end
        
    assert @step_check.notice
    assert !@step_check.save
    
    for element in persistent_attributes
    assert @step_check.errors.invalid?(element), "#{element} should have changed"
    end

  end
  
  def test_persistent_attributes_when_step_close
    @step_notice.notice
    
    persistent_attributes = ["employee", "start_date", "end_date", "start_half", "end_half", "leave_type_id", "responsible","checked_at", "responsible_agreement", "responsible_remarks", "observer", "observer_remarks", "acquired_leaves_days"]
    
    for element in persistent_attributes
      @step_notice.send("#{element}=",nil)
    end
        
    assert @step_notice.close
    assert !@step_notice.save
    
    for element in persistent_attributes
    assert @step_notice.errors.invalid?(element), "#{element} should have changed"
    end

  end
    
end
