require File.dirname(__FILE__) + '/../sales_test'

class ProductReferenceSubCategoryTest < ActiveSupport::TestCase
  
  #has_permissions :as_business_object
  #has_reference   :symbols => [:product_reference_category], :prefix => :sales
  
  should_belong_to :product_reference_category
  
  should_have_many :product_references, :disabled_product_references, :all_product_references
  
  #validates_persistence_of :product_reference_category_id, :unless => :can_update_product_reference_category_id?
  
  context "A product_reference_sub_category" do
    setup do
      @product_reference_category = product_reference_categories(:child)
    end
    
    subject{ @product_reference_category }
    
    include ProductReferenceCategoryBaseTest
  end

end
