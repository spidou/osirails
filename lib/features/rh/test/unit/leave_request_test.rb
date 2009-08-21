require 'test/test_helper'

class LeaveRequestTest < ActiveSupport::TestCase

  def setup         
    @employee = employees(:trish_doe)
    @superior = employees(:johnny)
    @leave_type = leave_types(:good_leave_type)
    
    flunk "@employee should be valid to perform the following tests" unless @employee.valid?
    flunk "@superior should be valid to perform the following tests" unless @superior.valid?
    flunk "@leave_type should be valid to perform the following tests" unless @leave_type.valid?
    
    @leave_request = LeaveRequest.new  
    flunk "@leave_request should NOT be valid to perform the following tests" if @leave_request.valid?
  end
  
  def teardown
    @leave_request = nil
    @in_progress_leave_request = nil
    @employee = nil
    @superior = nil
    @leave_type = nil
  end

  def test_dates_validity_when_step_check
    prepare_to_check(@leave_request,true)
    @leave_request.start_date = Date.today - 1
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:start_date), "start_date should NOT be valid because it is before today"
    
    @leave_request.start_date = Date.today
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:start_date), "start_date should be valid"
  end 
  
  def test_dates_validity_when_step_notice
    prepare_to_check(@leave_request,true)
    prepare_to_notice(@leave_request)
    @leave_request.start_date = Date.today - 1
    
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:start_date), "start_date should NOT be valid because it is before today"
    
    @leave_request.start_date = Date.today
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:start_date), "start_date should be valid"
  end 
  
  def test_dates_validity_when_step_close
    prepare_to_check(@leave_request,true)
    prepare_to_notice(@leave_request)
    prepare_to_close(@leave_request,true)
    @leave_request.start_date = Date.today - 1
    
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:start_date), "start_date should NOT be valid because it is before today"
    
    @leave_request.start_date = Date.today
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:start_date), "start_date should be valid"
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
  
  def test_dates_coherence_order
    @leave_request.start_date = Date.today + 10
    @leave_request.end_date = @leave_request.start_date - 1
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:end_date), "end_date should NOT be valid because it's before start_date"
    
    @leave_request.end_date = @leave_request.start_date
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:end_date), "end_date should be valid"
  end
  
  def test_dates_coherence_validity
    @leave_request.start_date = Date.today
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:start_date), "start_date should be valid"
    
    @leave_request.start_date = Date.yesterday
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:start_date), "start_date should NOT be valid because it is before today"
  end
  
  def test_same_dates_and_a_half_max
    @leave_request.start_date = Date.today
    @leave_request.start_half  = true
    @leave_request.end_date = @leave_request.start_date
    @leave_request.end_half = @leave_request.start_half
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:end_half), "end_half should NOT be valid"
    
    @leave_request.end_half = false
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:end_half), "end_half should be valid"
  end
  
  def test_unique_dates
    prepare_to_submit(@leave_request)
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:start_date), "period should be valid"
    
    @leave_request.start_date = Date.today + 16
    @leave_request.end_date = Date.today + 16
    @leave_request.start_half = false
    @leave_request.end_half = false
    @leave_request.valid?

    assert @leave_request.errors.invalid?(:start_date), "period should NOT be valid"
    
    @leave_request.start_date = Date.today + 1
    @leave_request.end_date = Date.today + 40
    @leave_request.start_half = false
    @leave_request.end_half = false
    @leave_request.valid?
    assert @leave_request.errors.invalid?(:start_date), "period should NOT be valid"
    
    @leave_request.start_date = Date.today + 16
    @leave_request.end_date = Date.today + 16
    @leave_request.start_half = true
    @leave_request.end_half = true
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:start_date), "period should be valid"
    
    @leave_request.start_date = Date.today + 40
    @leave_request.end_date = Date.today + 40
    @leave_request.start_half = true
    @leave_request.end_half = false
    @leave_request.valid?
    assert !@leave_request.errors.invalid?(:start_date), "period should be valid"    
  end
  
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
      leave_request.responsible_remarks = agreement ? "ok" : "Manque d'effectif"
    end
    
    def prepare_to_notice(leave_request)
      leave_request.status = LeaveRequest::STATUS_CHECKED
      leave_request.observer = @superior
      leave_request.acquired_leaves_days = 15
      leave_request.observer_remarks = "ok"
      leave_request.duration = 1
    end
    
    def prepare_to_close(leave_request,agreement)
      leave_request.status = LeaveRequest::STATUS_NOTICED
      leave_request.director = @superior
      leave_request.director_agreement = true if agreement
      leave_request.director_remarks = "Pas de congé ce mois-ci" unless agreement
    end
    
end
