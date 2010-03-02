require 'test/test_helper'

class ThirdTest < ActiveSupport::TestCase
  
  should_belong_to :activity_sector, :legal_form
  
  should_validate_presence_of :name
  should_validate_presence_of :legal_form, :activity_sector, :with_foreign_key => :default
  
  should_allow_values_for :siret_number, "12345678901234", "09876543210987"
  should_not_allow_values_for :siret_number, "azert", "azertyuiopqsdf", "1234567890123", "123456789012345", "1234567890123a", "", nil
  
  should_allow_values_for :website, "http://www.mywebsite.com", "https://website.fr", "", nil
  should_not_allow_values_for :website, "www.website.com", "website", "http://website", "http://website."
  
end
