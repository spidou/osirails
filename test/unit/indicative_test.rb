require 'test/test_helper'

class IndicativeTest < ActiveSupport::TestCase
  should_belong_to :country
  
  should_validate_presence_of :indicative
  should_validate_presence_of :country, :with_foreign_key => :default
end
