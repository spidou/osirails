require File.dirname(__FILE__) + '/../has_address_test'

class CountryTest < ActiveSupport::TestCase
  should_have_many :cities, :regions
  
  should_validate_presence_of :name, :code
  should_validate_uniqueness_of :name
end
