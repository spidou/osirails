module ProductTest
  
  class << self
    def included base
      base.class_eval do
        
        should_validate_presence_of :name
        
        context "which is set to be destroyed" do
          setup do
            @product.should_destroy = "1"
            
            flunk "@product should be set to be destroyed" unless @product.should_destroy?
            flunk "@product.name should be nil" unless @product.name.nil?
            @product.valid?
          end
          
          should "not require name" do
            assert_nil @product.errors.on(:name)
          end
        end
        
      end
    end
  end
  
end
