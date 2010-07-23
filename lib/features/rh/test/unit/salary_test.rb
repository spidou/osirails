require File.dirname(__FILE__) + '/../rh_test'

class SalaryTest < ActiveSupport::TestCase
  def setup
    @salary = salaries(:john_doe_salary)
  end

  def test_presence_of_gross_amount
    salary = Salary.new
    salary.valid?
    assert salary.errors.invalid?(:gross_amount), "gross_amount should NOT be valid because it's nil"
  end

  def test_numericality_of_gross_amount
    salary = Salary.new(:gross_amount => "string")
    salary.valid?
    assert salary.errors.invalid?(:gross_amount), "gross_amount should NOT be valid because it's not a number"
    
    salary.gross_amount = 1000
    salary.valid?
    assert !salary.errors.invalid?(:gross_amount), "gross_amount should be valid because it's a fixnum"
    
    salary.gross_amount = 1000.00
    salary.valid?
    assert !salary.errors.invalid?(:gross_amount), "gross_amount should be valid because it's a float"
  end
end
