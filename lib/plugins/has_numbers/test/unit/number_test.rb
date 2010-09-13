require File.dirname(__FILE__) + '/../has_numbers_test'

class NumberTest < ActiveSupport::TestCase
  
#  def setup
#    @good_number = numbers(:normal)
#    flunk "good_number should be good " unless @good_number.valid?
##    flunk @good_number.inspect
#    
#    @number = Number.new
#    @number.valid?
#  end
#  
#  def teardown
#    @number      = nil
#    @good_number = nil
#  end
#  
#  def test_presence_of_has_number_type
#    assert @number.errors.invalid?(:has_number_type), "has_number_type should NOT be valid because it's nil"
#    assert !@good_number.errors.invalid?(:has_number_type), "has_number_type should be valid"
#  end
#  
#  def test_presence_of_indicative
#    assert @number.errors.invalid?(:indicative_id), "indicative_id should NOT be valid because it's nil"
#    
#    @number.indicative_id = 0
#    @number.valid?
#    assert !@number.errors.invalid?(:indicative_id), "indicative_id should be valid"
#    assert @number.errors.invalid?(:indicative), "indicative should NOT be valid because employee_id is wrong"
#    
#    assert !@good_number.errors.invalid?(:indicative_id), "indicative_id should be valid"
#    assert !@good_number.errors.invalid?(:indicative), "indicative should be valid"  
#  end
  
#  def test_presence_of_number_type
#    assert @number.errors.invalid?(:number_type_id), "number_type_id should NOT be valid because it's nil"
#    
#    @number.number_type_id = 0
#    @number.valid?
#    assert !@number.errors.invalid?(:number_type_id), "number_type_id should be valid"
#    assert @number.errors.invalid?(:number_type), "number_type should NOT be valid because number_type_id is wrong"
#    
#    assert !@good_number.errors.invalid?(:number_type_id), "number_type_id should be valid"
#    assert !@good_number.errors.invalid?(:number_type), "number_type should be valid"  
#  end
  
#  def test_visible
#    assert_equal @good_number.visible, @good_number.visible?
#  end
  
  should_belong_to :indicative, :number_type, :has_number
  
  should_journalize :attributes => :number, :identifier_method => :formatted
  
  should_validate_presence_of :has_number_type
  should_validate_presence_of :indicative, :with_foreign_key => :default
  
  context "A number" do
    setup do
      @number = Number.new(:number => "012345678")
    end
    
    should "have a well-formed stored number" do
      assert_equal "012345678", @number.number
    end
    
    should "store a well-formed number" do
      @number.number = "012345678"
      assert_equal "012345678", @number.number
    end
    
    should "store a well-formed number even with spaces" do
      @number.number = "012 34 56 78"
      assert_equal "012345678", @number.number
    end
    
    should "store a well-formed number even with too many spaces" do
      @number.number = "01 23 456 78"
      assert_equal "012345678", @number.number
    end
    
    context "with starts with '0'" do
      setup do
        flunk "@number should start with '0'" unless @number.number.starts_with?("0")
      end
      
      should "have a well-formed formatted_with_indicative number" do
        assert_equal "(0)12345678", @number.formatted_with_indicative
      end
    end
    
    context "with NOT starts with '0'" do
      setup do
        @number = Number.new(:number => "912345678")
        flunk "@number should NOT start with '0'" if @number.number.starts_with?("0")
      end
      
      should "have a well-formed formatted_with_indicative number" do
        assert_equal "912345678", @number.formatted_with_indicative
      end
    end
  end
  
end
