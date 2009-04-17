require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase
  def setup
    address = Address.create(:address1 => "1 rue des rosiers", :address2 => "", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
    iban = Iban.create :bank_name => "Bank", :bank_code => "12345", :branch_code => "12345", :account_number => "12345678901", :key => "12"
    @employee = Employee.create(:last_name => 'Pan',
                                :first_name => 'Peter',
                                :birth_date => Date.today - 20.years,
                                :email => "peter@pan.org", 
                                :society_email => "peter.pan@society.com",
                                :social_security_number => "1234567891234 45",
                                :address => address,
                                :iban => iban)
  end
  
  def test_read
    assert_nothing_raised "An Employee should be read" do
      Employee.find(@employee.id)
    end
  end
  
  def test_update
    assert_no_difference 'Employee.count' do
      assert @employee.update_attributes(:last_name => 'new last name'), "An Employee should be update"
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
      assert_not_nil employee.errors.on(:last_name), "An Employee should have a last name"
    end
  end
  
  def test_presence_of_first_name
    assert_no_difference 'Employee.count' do
      employee = Employee.create
      assert_not_nil employee.errors.on(:first_name), "An Employee should have a first name"
    end
  end
  
  def test_format_of_social_security_number
    assert_no_difference 'Employee.count' do
      employee = Employee.create(:social_security_number => 'a')
      assert_not_nil employee.errors.on(:social_security_number), "An Employee should have a correct social security number"
    end
  end
  
  def test_format_of_email
    assert_no_difference 'Employee.count' do
      employee = Employee.create(:email => 'peter@on_bird')
      assert_not_nil employee.errors.on(:email), "An Employee should have a correct email"
    end
  end
  
  def test_format_of_society_email
    assert_no_difference 'Employee.count' do
      employee = Employee.create(:society_email => 'peter@on_another_bird')
      assert_not_nil employee.errors.on(:society_email), "An Employee should have a correct society email"
    end
  end
end
