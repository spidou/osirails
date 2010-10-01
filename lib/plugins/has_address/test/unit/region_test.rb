require File.dirname(__FILE__) + '/../has_address_test'

class RegionTest < ActiveSupport::TestCase
  should_belong_to :country
  should_have_many  :cities
  
  should_validate_presence_of :name, :country_id
end
