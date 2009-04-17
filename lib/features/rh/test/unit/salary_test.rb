require 'test_helper'

class SalaryTest < ActiveSupport::TestCase
  def setup
    @salary = Salary.create(:job_contract_id => 1, :gross_amount => 3000)
  end
  
  def test_presence_of_job_contract_id
    assert_no_difference 'Salary.count' do
      salary = Salary.create
      assert_not_nil salary.errors.on(:contract_id), "A Salary should have a job contract id"
    end
  end
  
  def test_presence_of_gross_amount
    assert_no_difference 'Salary.count' do
      salary = Salary.create
      assert_not_nil salary.errors.on(:gross_amount), "A Salary should have a gross amount"
    end
  end
  
  def test_format_of_gross_amount
    @salary.update_attributes(:gross_amount => 'a')
    assert_not_nil @salary.errors.on(:gross_amount), "A Salary should have a numeric value for gross amount"
  end
end
