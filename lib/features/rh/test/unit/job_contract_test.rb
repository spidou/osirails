require 'test_helper'

class JobContractTest < ActiveSupport::TestCase
  fixtures :job_contracts

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

  def test_salary
    # TODO Test salary for JobContractTest
  end
end
