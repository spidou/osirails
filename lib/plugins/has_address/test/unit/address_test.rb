require File.dirname(__FILE__) + '/../has_address_test'

class AddressTest < ActiveSupport::TestCase
  should_belong_to :has_address#, :polymorphic => true
  
  should_validate_presence_of :has_address_type, :has_address_key, :street_name, :country_name, :city_name
  
  should_validate_numericality_of :zip_code
  
  should_journalize :attributes        => [ :street_name, :city_name, :country_name, :zip_code ],
                    :identifier_method => :formatted
end
