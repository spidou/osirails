require 'test_helper'

class JobContractTest < ActiveSupport::TestCase
  fixtures :job_contracts, :salaries

  def setup
    @job_contract = job_contracts(:normal)
  end

  def test_presence_of_employee_id
    assert_no_difference 'JobContract.count' do
      job_contract = JobContract.create
      assert_not_nil job_contract.errors.on(:employee_id), "A JobContract should have an employee id"
    end
  end

  def test_presence_of_employee_state_id
    assert_no_difference 'JobContract.count' do
      job_contract = JobContract.create
      assert_not_nil job_contract.errors.on(:employee_state_id), "A JobContract should have an employee state id"
    end
  end

  def test_presence_of_job_contract_type_id
    assert_no_difference 'JobContract.count' do
      job_contract = JobContract.create
      assert_not_nil job_contract.errors.on(:job_contract_type_id), "A JobContract should have a job contract type id"
    end
  end

  def test_actual_salary
    assert_equal @job_contract.actual_salary, salaries(:normal),
      "This JobContract should have this actual salary as Salary"
  end

  def test_salary
    assert_equal @job_contract.salary, salaries(:normal).gross_amount,
      "This JobContract should have this actual salary as Salary"
  end

  def test_affect_and_save_salary
    assert_no_difference 'Salary.count' do
      @job_contract.salary = 3000
      @job_contract.save
    end

    assert_difference 'Salary.count', +1 do
      @job_contract.salary = @job_contract.salary + 1000
      @job_contract.save
    end
  end
end
