require 'test/test_helper'

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + '/fixtures/'

class Test::Unit::TestCase
  fixtures :all
  
  def build_valid_employee
    Employee.new do |e|
      e.civility   = Civility.first
      e.first_name = "John"
      e.last_name  = "Doe"
      e.service    = Service.first
      e.jobs       = [ Job.first ]
      e.build_employee_sensitive_data(
        :family_situation        => FamilySituation.first,
        :birth_date              => Date.parse("1980/01/01"),
        :social_security_number  => "1234567891011 12")
      e.employee_sensitive_data.build_address(
        :street_name => "1 rue des rosiers",
        :city_name => "Paris",
        :zip_code => "75000",
        :country_name => "France")
    end
  end
  
  
end
