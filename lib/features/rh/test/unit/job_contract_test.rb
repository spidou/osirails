require File.dirname(__FILE__) + '/../rh_test'

class JobContractTest < ActiveSupport::TestCase
  should_belong_to :employee, :job_contract_type
  
  should_have_many :salaries
  should_have_one :actual_salary
  
  should_journalize :attributes => [ :job_contract_type_id, :start_date, :end_date, :departure ],
                    :subresources => [:salaries]
  
  should_validate_presence_of :start_date
  should_validate_presence_of :job_contract_type, :with_foreign_key => :default
                    
  context "A Job_contract" do
    setup do
      @employee = build_valid_employee
      @employee.save
      @job_contract = JobContract.new do |j|
        j.employee          = @employee  
        j.start_date        = "1-1-1960"
        j.end_date          = nil
        j.job_contract_type = job_contract_types(:not_limited_contract)
        j.departure         = nil
        j.departure_description = nil
      end
      flunk "@job_contract should be valid #{ @job_contract.errors.inspect }" unless @job_contract.valid?
    end
    
    should "be valid" do
      assert @job_contract.valid?
    end
    
    context "is a new record and have not limited job_contract_type" do
      setup do
        @job_contract.end_date = "1-2-1960"
      end  
      
      should "require end_date to be nil" do
        assert !@job_contract.valid?
        assert @job_contract.errors.invalid?(:end_date)
      end
    end
    
    context "with start_date after end_date" do
      setup do
        @job_contract.job_contract_type = job_contract_types(:limited_contract)
        @job_contract.start_date = "1-10-1960"
        @job_contract.end_date   = "1-9-1960"
        @job_contract.valid?
      end  
      
      should "be invalid" do
        assert !@job_contract.valid?
      end
      
      should "require start_date to be before end_date" do
        assert @job_contract.errors.invalid?(:start_date)
      end
      
      should "require end_date to be after start_date" do
        assert @job_contract.errors.invalid?(:end_date)
      end
    end
    
    context "with departure" do
      setup do
        @job_contract.departure = "1-2-1960"
      end  
      
      should "require departure_description" do
        assert !@job_contract.valid?
        assert @job_contract.errors.invalid?(:departure_description)
      end
    end
    
    context "with bad departure" do
      setup do
        @job_contract.departure = "1-2-1960"
        @job_contract.start_date = "1-3-1960"
      end  
      
      should "require departure to be after start_date" do
        assert !@job_contract.valid?
        assert @job_contract.errors.invalid?(:departure)
      end
    end
  end
#  
#  def setup
#    @job_contract = job_contracts(:normal_job_contract)
#  end

#  #TODO active this test once job_contract_type is required (with validates_presence_of)
##  def test_presence_of_job_contract_type
##    jc = JobContract.new
##    jc.valid?
##    assert jc.errors.invalid?(:job_contract_type_id), "job_contract_type_id should NOT be valid because it's nil"
##    
##    jc.job_contract_type_id = 0
##    jc.valid?
##    assert jc.errors.invalid?(:job_contract_type), "job_contract_type should NOT be valid because job_contract_type_id is bad"
##    
##    jc.job_contract_type_id = job_contract_types(:rolling_contract).id
##    jc.valid?
##    assert !jc.errors.invalid?(:job_contract_type_id), "job_contract_type_id should be valid"
##    assert !jc.errors.invalid?(:job_contract_type), "job_contract_type should be valid"
##    
##    jc.job_contract_type = job_contract_types(:rolling_contract)
##    jc.valid?
##    assert !jc.errors.invalid?(:job_contract_type_id), "job_contract_type_id should be valid"
##    assert !jc.errors.invalid?(:job_contract_type), "job_contract_type should be valid"
##  end

#  def test_actual_salary
#    assert_equal @job_contract.actual_salary, salaries(:normal_salary),
#      "This JobContract should have this actual salary as Salary"
#  end

#  def test_salary
#    assert_equal @job_contract.salary, salaries(:normal_salary).gross_amount,
#      "This JobContract should have this actual salary as Salary"
#  end
#  
#  #TODO review the process of management of salaries, and write the correct unit test
#  # by now, a salary is attached on a job contract. While updating the job contract, if the salary is
#  # similar to the actual salary, we don't create a new salary, otherwise we create a new salary entry.
#  
##  def test_affect_and_save_salary
##    flunk "Fixture salary called 'normal' should have a gross_amount at 3000" if @job_contract.salary != 3000
##    
##    assert_no_difference 'Salary.count', 'Salary should not be saved because the previous value was already at 3000' do
##      @job_contract.salary = 3000
##      @job_contract.save!
##    end
##
##    assert_difference 'Salary.count', +1, 'Salary should be saved' do
##      @job_contract.salary = 4000
##      @job_contract.save!
##    end
##  end
end
