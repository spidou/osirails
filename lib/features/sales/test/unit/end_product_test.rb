require File.dirname(__FILE__) + '/../sales_test'
 
class EndProductTest < ActiveSupport::TestCase
  should_belong_to :product_reference, :order
  
  should_have_many :checklist_responses, :quote_items, :mockups, :press_proofs
  
  should_validate_presence_of :product_reference, :order, :with_foreign_key => :default
  
  should_validate_presence_of :name
  
  should_validate_numericality_of :quantity, :prizegiving
  
  should_journalize :identifier_method => :name

  # TODO  
  #validates_numericality_of :vat, :if => Proc.new{ |p| p.quote_items.reject{ |i| i.quote.cancelled? }.any? } # run validation if product is associated with at least 1 quote_item which provide from a non-cancelled quote
  
  # TODO
  # validates_persistence_of :product_reference_id, :order_id
  
  context "A saved end_product" do
    setup do
      @end_product = create_default_end_product
    end
    
    context "with 1 product_reference" do # ancestors <=> product_reference and its product_reference_categories
      setup do
        flunk "@end_product should have a product_reference" unless @end_product.product_reference
        flunk "@end_product should be named 'Default End Product'" unless @end_product.name == "Default End Product"
      end
      
      context "without dimensions" do
        setup do
          flunk "@end_product should have no dimensions" unless @end_product.dimensions.blank?
        end
        
        should "have a good designation" do
          expected_value = "Default End Product" # name
          assert_equal expected_value, @end_product.designation
        end
      end
      
      context "with dimensions" do
        setup do
          @end_product.dimensions = "1000 x 2000"
        end
        
        should "have a good designation" do
          expected_value = "Default End Product (1000 x 2000)" # name (dimensions)
          assert_equal expected_value, @end_product.designation
        end
      end
    end
  end
  
  context "A saved end_product" do
    setup do
      @product = create_default_end_product
    end
    
    subject{ @product }
    
    include ProductTest
  end
end
