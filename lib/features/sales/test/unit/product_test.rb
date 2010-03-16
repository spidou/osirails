require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'

class ProductTest < ActiveSupport::TestCase
  include ProductBaseTest
  
  should_belong_to :product_reference
  should_belong_to :order
  
  should_have_many :checklist_responses
  should_have_many :quote_items
  should_have_many :press_proofs
  should_have_many :mockups
  
  should_validate_presence_of :name
  should_validate_presence_of :order, :product_reference, :with_foreign_key => :default
  
  should_validate_numericality_of :prizegiving, :quantity
  
  should_allow_values_for :prizegiving, nil
  
  should_allow_values_for     :quantity, 0, 1, 1.0
  should_not_allow_values_for :quantity, nil, "", "any string"
  
  #TODO validates_numericality_of :unit_price, :vat, :unless => Proc.new{ |p| p.quote_items.reject{ |i| i.quote.cancelled? }.empty? }
  
  #should_validate_presence_of :reference   #TODO when quote is signed
  #should_validate_uniqueness_of :reference #TODO when quote is signed
  
  context "A Product referenced into a signed press_proof" do
    setup do
      order       = create_default_order
      @product    = create_valid_product_for(order)
      press_proof = create_default_press_proof(order, @product)
      get_signed_press_proof(press_proof)
    end
    
    teardown do
      @product = nil
    end
    
    should "have a signed press_proof" do
      assert @product.has_signed_press_proof?
    end
  end
  
end
