require File.dirname(__FILE__) + '/../thirds_test'

class CustomerTest < ActiveSupport::TestCase
  should_belong_to :factor, :customer_grade, :customer_solvency
  should_have_one :head_office
  should_have_many :establishments
  
  should_have_attached_file :logo
  
  should_validate_presence_of   :head_office
  should_validate_uniqueness_of :name
  
  should_journalize :attributes        => [ :name, :legal_form_id, :company_created_at, :collaboration_started_at, :factor_id, :customer_solvency_id, :customer_grade_id, :activated ],
                    :attachments       => :logo,
                    :subresources      => [ :head_office, :establishments, :bill_to_address ],
                    :identifier_method => :name

  context "A new customer" do
    setup do
      @customer = Customer.new
    end
    
    teardown do
      @customer = nil
    end
    
    #TODO test when siret numbers are nil
    #     test if customer.establishments is invalid
    # test validates_uniqueness_of_siret_number
    context "with sub resources having similar siret_numbers except one" do
      setup do
        @head_office = @customer.build_head_office(:siret_number => "11111111111110")
        @est1 = @customer.establishments.build(:siret_number => "11111111111110")
        @est2 = @customer.establishments.build(:siret_number => "11111111111110")
        @est3 = @customer.establishments.build(:siret_number => "11111111111112")
        @customer.valid?
      end
      
      teardown do
        @head_office = nil
        @est1 = nil
        @est2 = nil
        @est3 = nil
      end
      
      should "invalid @head_office because siret_number is alreday taken" do
        assert @head_office.errors.invalid?(:siret_number)
      end
      
      should "invalid @est1 because siret_number is alreday taken" do
        assert @est1.errors.invalid?(:siret_number)
      end
      
      should "invalid @est2 because siret_number is alreday taken" do
        assert @est2.errors.invalid?(:siret_number)
      end
      
      should "valid @est3 because it has different siret_number" do
        assert !@est3.errors.invalid?(:siret_number)
      end
    end
  end  
end
