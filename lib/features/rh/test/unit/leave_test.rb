require 'test/test_helper'
require File.dirname(__FILE__) + '/leave_base_test'
require File.dirname(__FILE__) + '/leave_validations_test'

class LeaveTest < ActiveSupport::TestCase
  include LeaveBaseTest
  include LeaveValidationsTest
  
  def setup
    @employee = employees(:trish_doe)
    @leave_type = leave_types(:good_leave_type)
    
    @good_leave = Leave.new(:start_date     => Date.today.next_month.monday,
                            :end_date       => Date.today.next_month.monday + 6.days,
                            :start_half     => true,
                            :end_half       => true,
                            :duration       => 6,
                            :employee_id    => @employee.id,
                            :leave_type_id  => @leave_type.id)
    flunk "good_leave should be saved to perform the following > #{@good_leave.errors.inspect}" unless @good_leave.save
    
    ConfigurationManager.admin_society_identity_configuration_leave_year_start_date = (Date.today - 11.months).strftime("%m/%d")
    
    @leave = Leave.new
    @leave.valid?
    
    setup_leaves
  end
  
  def teardown
    @good_leave = nil
    @leave = nil
  end
  
  def test_persistence_of_cancelled
    assert !@good_leave.errors.invalid?(:cancelled), "cancelled should be valid because is not modified"
    
    @good_leave.cancelled = true
    @good_leave.valid?
    assert @good_leave.errors.invalid?(:cancelled), "cancelled should NOT be valid because it can't be modified while a normal edit"
  end
  
  def test_persistence_of_employee_id
    assert !@good_leave.errors.invalid?(:employee_id), "employee_id should be valid because is not modified"
    
    @good_leave.employee_id = employees(:james_doe).id
    @good_leave.valid?
    assert @good_leave.errors.invalid?(:employee_id), "employee_id should NOT be valid because is modified"
  end
  
  def test_presence_of_start_date
    assert @leave.errors.invalid?(:start_date), "start_date should NOT be valid because it's nil"
    assert !@good_leave.errors.invalid?(:start_date), "start_date should be valid"
  end
  
  def test_presence_of_end_date
    assert @leave.errors.invalid?(:end_date), "end_date should NOT be valid because it's nil"
    assert !@good_leave.errors.invalid?(:end_date), "end_date should be valid"
  end
  
  def test_numericality_of_duration
    assert @leave.errors.invalid?(:duration), "duration should NOT be valid because it's nil"
    
    @leave.duration = "string"
    @leave.valid?
    assert @leave.errors.invalid?(:duration), "duration should NOT be valid because it's not a numerical value"
    assert !@good_leave.errors.invalid?(:duration), "duration should be valid"
  end
  
  def test_presence_of_leave_type
    assert @leave.errors.invalid?(:leave_type_id), "leave_type_id should NOT be valid because it's nil"
    
    @leave.leave_type_id = 0
    @leave.valid?
    assert !@leave.errors.invalid?(:leave_type_id), "leave_type_id should be valid"
    assert @leave.errors.invalid?(:leave_type), "leave_type should NOT be valid because employee_id is wrong"
    
    assert !@good_leave.errors.invalid?(:leave_type_id), "leave_type_id should be valid"
    assert !@good_leave.errors.invalid?(:leave_type), "leave_type should be valid"  
  end
  
  def test_presence_of_employee
    assert @leave.errors.invalid?(:employee_id), "employee_id should NOT be valid because it's nil"
    
    @leave.employee_id = 0
    @leave.valid?
    assert !@leave.errors.invalid?(:employee_id), "employee_id should be valid"
    assert @leave.errors.invalid?(:employee), "employee should NOT be valid because employee_id is wrong"
    
    assert !@good_leave.errors.invalid?(:employee_id), "employee_id should be valid"
    assert !@good_leave.errors.invalid?(:employee), "employee should be valid"  
  end
  
  def test_not_cancelled_at_creation
    assert !@leave.errors.invalid?(:cancelled), "cancelled should be valid because nil is allowed"
    
    @leave.cancelled = true
    @leave.valid?
    assert @leave.errors.invalid?(:cancelled), "cancelled should NOT be valid because cancelled is true for a new record"   
    @leave.cancelled = false
    @leave.valid?
    assert !@leave.errors.invalid?(:cancelled), "cancelled should be valid"
  end
  
  def test_cancel
    assert_equal true, @good_leave.cancel, "@good_leave should be valid "
    
    @good_leave.reload.start_date = nil
    assert_equal false, @good_leave.cancel, "@good_leave should NOT be valid because of a validation error" 
  end
  
  def test_can_be_edited
    flunk "@good_leave should NOT be cancelled to perform the following" if @good_leave.cancelled
    
    assert @good_leave.can_be_edited?, "@good_leave should be editable"
    
    flunk "@good_leave shoud be cancelled" unless @good_leave.cancel
    
    assert !@good_leave.can_be_edited?, "@good_leave should NOT be editable"
  end
  
  def test_can_be_cancelled
    flunk "@good_leave should NOT be cancelled to perform the following" if @good_leave.cancelled
    
    assert @good_leave.can_be_cancelled?, "@good_leave should be cancellable"
    
    flunk "@good_leave shoud be cancelled" unless @good_leave.cancel
    
    assert !@good_leave.can_be_cancelled?, "@good_leave should NOT be cancellable"
  end
  
  def test_persistence_of_attributes
    hash = {:start_date    => @good_leave.start_date + 1,
            :end_date      => @good_leave.end_date + 2,
            :start_half    => !@good_leave.start_half,
            :end_half      => !@good_leave.end_half,
            :leave_type_id => leave_types(:leave_type_to_test_edit).id,
            :duration      => @good_leave.duration + 1}
            
    # when leave IS NOT cancelled
    hash.each do |attribute, new_value|
      flunk "new value of '#{attribute}' should NOT be equal to '#{new_value}' to perform the following" if @good_leave.send(attribute) == new_value
      
      assert !@good_leave.errors.invalid?(attribute), "#{attribute.to_s} should be valid because it's not modified"
      
      @good_leave.send("#{attribute.to_s}=", new_value)
      @good_leave.valid?
      assert !@good_leave.errors.invalid?(attribute), "#{attribute.to_s} should be valid because a leave can be modified if it's not cancelled"
    end
    
    # when leave IS cancelled
    flunk "@good_leave should be cancelled to perform the following" unless @good_leave.reload.cancel
    hash.each do |attribute, new_value|
      flunk "new value of '#{attribute}' should NOT be equal to '#{new_value}' to perform the following" if @good_leave.send(attribute) == new_value
      
      assert !@good_leave.errors.invalid?(attribute), "#{attribute.to_s} should be valid because it's not modified"
      
      @good_leave.send("#{attribute.to_s}=", new_value)
      @good_leave.valid?
      assert @good_leave.errors.invalid?(attribute), "#{attribute.to_s} should NOT be valid because a leave can't modified if it's cancelled"
    end
  end
end
