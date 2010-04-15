require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'

class SubcontractorTest < ActiveSupport::TestCase
  
  context "A subcontractor" do
    setup do
      @siret_number_owner = Subcontractor.new
    end
    
    subject{ @siret_number_owner }
    
    include SiretNumberTest
  end
  
end
