require 'test/test_helper'

class NumberTest < ActiveSupport::TestCase
  
  def setup
    @good_number = numbers(:normal)
    flunk "good_number should be good " unless @good_number.valid?
#    flunk @good_number.inspect
    
    @number = Number.new
    @number.valid?
  end
  
  def teardown
    @number      = nil
    @good_number = nil
  end
  
  def test_presence_of_has_number_type
    assert @number.errors.invalid?(:has_number_type), "has_number_type should NOT be valid because it's nil"
    assert !@good_number.errors.invalid?(:has_number_type), "has_number_type should be valid"
  end
  
  def test_presence_of_indicative
    assert @number.errors.invalid?(:indicative_id), "indicative_id should NOT be valid because it's nil"
    
    @number.indicative_id = 0
    @number.valid?
    assert !@number.errors.invalid?(:indicative_id), "indicative_id should be valid"
    assert @number.errors.invalid?(:indicative), "indicative should NOT be valid because employee_id is wrong"
    
    assert !@good_number.errors.invalid?(:indicative_id), "indicative_id should be valid"
    assert !@good_number.errors.invalid?(:indicative), "indicative should be valid"  
  end
  
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
  
  def test_formatted
    assert_equal '0262 11 22 33', @good_number.formatted
  end
  
  def test_visible
    assert_equal @good_number.visible, @good_number.visible?
  end
  
  def test_should_destroy
    assert_equal @good_number.should_destroy.to_i == 1, @good_number.should_destroy?
  end
  
end
