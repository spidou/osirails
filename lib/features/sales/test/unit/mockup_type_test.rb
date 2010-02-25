require 'test/test_helper'

class MockupTypeTest < ActiveSupport::TestCase
  should_have_many :mockups
  
  should_validate_presence_of :name
  
  context "A mockup type" do
    setup do  
      @mt = mockup_types(:normal)
      flunk "@mt should be valid" unless @mt.valid?
    end
    
    subject { @mt }
    
    should_validate_uniqueness_of :name
  end
end
