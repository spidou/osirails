require 'leave_and_leave_request/leave_base'
require 'leave_and_leave_request/leave_validations'

module LeaveAndLeaveRequest
  include LeaveBase
  include LeaveValidations
end
