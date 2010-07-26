require 'test/test_helper'
require File.dirname(__FILE__) + '/../purchases_test'

class PurchaseRequestTest < ActiveSupport::TestCase
  
  should_have_many :purchase_request_supplies
  should_belong_to :user, :employee, :service
  
  should_validate_presence_of :user_id, :employee_id, :service_id
  
  context "a new purchase_request" do
    
    setup do
      @purchase_request = PurchaseRequest.new(:user_id => 1, :employee_id => 2, :service_id => 3)
    end
    subject {@purchase_request}
    
    context "without purchase request supplies" do 
     
      should "be invalid" do
        assert_match /Veuillez selectionner au moins une matiere premiere ou un consommable/, @purchase_request.errors.on(:purchase_request_supplies)
      end
    end
    
    context "with at least one purchase request supply" do 
      
      setup do
        @purchase_request = build_purchase_request_supply_for(purchase_request)
      end
      
      should "be valid" do
        @purchase_request.valid?
        assert @purchase_request.errors.empty?
      end
    end
    
  end
end
