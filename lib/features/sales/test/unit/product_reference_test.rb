require File.dirname(__FILE__) + '/../sales_test'
 
class ProductReferenceTest < ActiveSupport::TestCase
  should_belong_to :product_reference_sub_category
  
  should_validate_presence_of :product_reference_sub_category, :with_foreign_key => :default
  
  context "A product_reference" do
    setup do
      @product_reference = ProductReference.new
    end
    
    context "with a product_reference_sub_category" do
      setup do
        @parent = product_reference_categories(:child)
        flunk "@parent should have a parent product_reference_category" unless @parent.product_reference_category
        
        @product_reference.product_reference_sub_category = @parent
      end
      
      should "have a valid product_reference_sub_category_id" do
        @product_reference.valid?
        assert_nil @product_reference.errors.on(:product_reference_sub_category_id)
      end
    end
  end
  
  context "A saved product_reference" do
    setup do
      @product_reference = create_default_product_reference
    end
    
    context "with 2 ancestors" do # ancestors <=> product_reference_categories
      setup do
        flunk "@product_reference should have a parent named 'Child category'" unless @product_reference.product_reference_sub_category and @product_reference.product_reference_sub_category.name == "Child category"
        flunk "@product_reference should have a parent which has a parent named 'Parent category'" unless @product_reference.product_reference_sub_category.product_reference_category and @product_reference.product_reference_sub_category.product_reference_category.name == "Parent category"
        flunk "@product_reference should be named 'Default Product Reference'" unless @product_reference.name == "Default Product Reference"
      end
      
      context "without dimensions" do
        setup do
          flunk "@product_reference should have no dimensions" unless @product_reference.dimensions.blank?
        end
        
        should "have a well-formed designation" do
          expected_value = "Parent category Child category Default Product Reference" # ancestor_names + self_name
          assert_equal expected_value, @product_reference.designation
        end
        
        should "have a well-formed designation_with_dimensions" do
          expected_value = "Parent category Child category Default Product Reference" # ancestor_names + self_name
          assert_equal expected_value, @product_reference.designation_with_dimensions
        end
      end
      
      context "with dimensions" do
        setup do
          @product_reference.width = 1000
          @product_reference.length = 2000
        end
        
        should "have a well-formed designation" do
          expected_value = "Parent category Child category Default Product Reference" # ancestor_names + self_name
          assert_equal expected_value, @product_reference.designation
        end
        
        should "have a well-formed designation_with_dimensions" do
          expected_value = "Parent category Child category Default Product Reference (1000 x 2000 mm)" # ancestor_names + self_name + dimensions
          assert_equal expected_value, @product_reference.designation_with_dimensions
        end
      end
    end
  end
  
  context "A new product_reference" do
    setup do
      @product = ProductReference.new
    end
    
    subject{ @product }
    
    include ProductTest
  end
end
