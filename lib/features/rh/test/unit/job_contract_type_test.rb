require 'test/test_helper'

class JobContractTypeTest < ActiveSupport::TestCase
  fixtures :job_contract_types

  def setup
    @job_contract_type = job_contract_types(:cdi)
  end

  def test_presence_of_name
    assert_no_difference 'JobContractType.count' do
      job_contract_type = JobContractType.create
      assert_not_nil job_contract_type.errors.on(:name),
        "A JobContractType should have a name"
    end
  end

  def test_presence_of_limited
    assert_no_difference 'JobContractType.count' do
      job_contract_type = JobContractType.create
      assert_not_nil job_contract_type.errors.on(:limited),
        "A JobContractType should have a limited value"
    end
  end
end
