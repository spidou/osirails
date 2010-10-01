require File.dirname(__FILE__) + '/../has_address_test'

class AddressTest < ActiveSupport::TestCase
  should_belong_to :has_address
  
  should_journalize :attributes        => [ :street_name, :zip_code, :city_name, :region_name, :country_name ],
                    :identifier_method => :formatted
                    
  should_validate_presence_of :has_address_type, :has_address_key, :street_name, :country_name, :city_name, :zip_code
end
