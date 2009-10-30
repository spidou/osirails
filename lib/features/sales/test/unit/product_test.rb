require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'

class ProductTest < ActiveSupport::TestCase
  
  should_belong_to :product_reference
  should_belong_to :order
  
  should_have_many :checklist_responses
  
  should_validate_presence_of :name, :description, :dimensions
  should_validate_presence_of :order, :product_reference, :with_foreign_key => :default
  
  should_validate_numericality_of :quantity
  
  #should_validate_presence_of :reference   #TODO when quote is signed
  #should_validate_uniqueness_of :reference #TODO when quote is signed
  
  context "A non saved product" do
    setup do
      @product = Product.new
    end
    
    #should "not have a summary" do
    #  assert_nil @product.summary
    #end
  end
  
  context "A valid saved product" do
    setup do
      @order    = create_default_order
      @product  = create_valid_product_for(@order)
    end
    
    #should "have a well-formed summary" do
    #  assert_equal "#{@product.quantity}x #{@product.name} (#{@product.dimensions})", @product.summary
    #end
    
    context "with unsaved modifications" do
      setup do
        @product.quantity   += 10
        @product.name       += "string"
        @product.dimensions += "string"
      end
      
      #should "have a well-formed summary with original attributes" do
      #  assert_equal "#{@product.quantity_was}x #{@product.name_was} (#{@product.dimensions_was})", @product.summary
      #end
    end
  end
  
end
