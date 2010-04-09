require 'test/test_helper'

class ThirdTest < ActiveSupport::TestCase
  
  should_belong_to :legal_form
  
  should_validate_presence_of :name
  should_validate_presence_of :legal_form, :with_foreign_key => :default
  
  should_allow_values_for :website, "http://www.mywebsite.com", "https://website.fr", "", nil
  should_not_allow_values_for :website, "www.website.com", "website", "http://website", "http://website."
  
end
