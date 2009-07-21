require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase
  fixtures :employees, :civilities

  def setup
    @employee = employees(:john_doe)
  end

  def test_read
    assert_nothing_raised "An Employee should be read" do
      Employee.find(@employee.id)
    end
  end
  
  def test_create
    assert_difference 'Employee.count', +1, "Employee should be created" do
      e = Employee.create(@employee.attributes)
    end
  end

  def test_delete
    assert_difference 'Employee.count', -1, "An Employee should be destroy" do
      @employee.destroy
    end
  end

  def test_presence_of_last_name
    assert_no_difference 'Employee.count' do
      employee = Employee.create
      assert_not_nil employee.errors.on(:last_name),
        "An Employee should have a last name"
    end
  end

  def test_presence_of_first_name
    assert_no_difference 'Employee.count' do
      employee = Employee.create
      assert_not_nil employee.errors.on(:first_name),
        "An Employee should have a first name"
    end
  end

  def test_format_of_social_security_number
    assert_no_difference 'Employee.count' do
      employee = Employee.create(:social_security_number => 'a')
      assert_not_nil employee.errors.on(:social_security_number),
        "An Employee should have a correct social security number"
    end
  end

  def test_format_of_email
    assert_no_difference 'Employee.count' do
      employee = Employee.create(:email => 'peter@on_bird')
      assert_not_nil employee.errors.on(:email),
        "An Employee should have a correct email"
    end
  end

  def test_format_of_society_email
    assert_no_difference 'Employee.count' do
      employee = Employee.create(:society_email => 'peter@on_another_bird')
      assert_not_nil employee.errors.on(:society_email),
        "An Employee should have a correct society email"
    end
  end
end
