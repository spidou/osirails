require 'test/test_helper'

class NumberTypeTest < ActiveSupport::TestCase

  def setup
    @good_number_type = number_types(:mobile)
    
    @number_type = NumberType.new
    @number_type.save
  end
  
  def teardown
    @good_number_type = nil
    @number_type      = nil
  end
  
  def test_presence_of_name
    assert @number_type.errors.invalid?(:name), "name should NOT be valid because it's nil"
    assert !@good_number_type.errors.invalid?(:name), "name should be valid"
  end
  
end
