require 'test_helper'

class JobContractTest < ActiveSupport::TestCase
  fixtures :job_contracts, :salaries, :job_contract_types

  def setup
    @job_contract = job_contracts(:normal)
  end

  #TODO active this test once job_contract_type is required (with validates_presence_of)
#  def test_presence_of_job_contract_type
#    jc = JobContract.new
#    jc.valid?
#    assert jc.errors.invalid?(:job_contract_type_id), "job_contract_type_id should NOT be valid because it's nil"
#    
#    jc.job_contract_type_id = 0
#    jc.valid?
#    assert jc.errors.invalid?(:job_contract_type), "job_contract_type should NOT be valid because job_contract_type_id is bad"
#    
#    jc.job_contract_type_id = job_contract_types(:cdi).id
#    jc.valid?
#    assert !jc.errors.invalid?(:job_contract_type_id), "job_contract_type_id should be valid"
#    assert !jc.errors.invalid?(:job_contract_type), "job_contract_type should be valid"
#    
#    jc.job_contract_type = job_contract_types(:cdi)
#    jc.valid?
#    assert !jc.errors.invalid?(:job_contract_type_id), "job_contract_type_id should be valid"
#    assert !jc.errors.invalid?(:job_contract_type), "job_contract_type should be valid"
#  end

  def test_actual_salary
    assert_equal @job_contract.actual_salary, salaries(:normal),
      "This JobContract should have this actual salary as Salary"
  end

  def test_salary
    assert_equal @job_contract.salary, salaries(:normal).gross_amount,
      "This JobContract should have this actual salary as Salary"
  end
  
  #TODO review the process of management of salaries, and write the correct unit test
  # by now, a salary is attached on a job contract. While updating the job contract, if the salary is
  # similar to the actual salary, we don't create a new salary, otherwise we create a new salary entry.
  
#  def test_affect_and_save_salary
#    flunk "Fixture salary called 'normal' should have a gross_amount at 3000 to perform the following tests" if @job_contract.salary != 3000
#    
#    assert_no_difference 'Salary.count', 'Salary should not be saved because the previous value was already at 3000' do
#      @job_contract.salary = 3000
#      @job_contract.save!
#    end
#
#    assert_difference 'Salary.count', +1, 'Salary should be saved' do
#      @job_contract.salary = 4000
#      @job_contract.save!
#    end
#  end
end
