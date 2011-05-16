require File.dirname(__FILE__) + '/../sales_test'

class MockProduct < ActiveRecord::Base
  include Tableless
  
  column :width, :integer
  column :length, :integer
  column :height, :integer
  
  include ProductDimensions
end

class ProductDimensionsTest < ActiveSupport::TestCase
  
  context "An object (which include ProductDimensions)" do
    setup do
      @o = MockProduct.new
    end
    
    subject{ @o }
    
    should_validate_numericality_of :width, :length, :height
    
    # test validates dimensions greater than 0
    context "with width equal to 0" do
      setup do
        @o.width = 0
        @o.valid?
      end
      
      should "have an invalid width" do
        assert_contain_error @o, :width, "must be greater than 0"
      end
    end
    
    # test validates dimensions greater than 0
    context "with length equal to 0" do
      setup do
        @o.length = 0
        @o.valid?
      end
      
      should "have an invalid length" do
        assert_contain_error @o, :length, "must be greater than 0"
      end
    end
    
    # test validates dimensions greater than 0
    context "with height equal to 0" do
      setup do
        @o.height = 0
        @o.valid?
      end
      
      should "have an invalid height" do
        assert_contain_error @o, :height, "must be greater than 0"
      end
    end
    
    # test validates width needs length
    context "with width is not nil, but length is nil" do
      setup do
        @o.width = 1000
        
        flunk "length should be nil" if @o.length
        
        @o.valid?
      end
      
      should "have invalid length" do
        assert_contain_error @o, :length, "can't be blank"
      end
    end
    
    # test validates length needs width
    context "with length is not nil, but width is nil" do
      setup do
        @o.length = 1000
        
        flunk "width should be nil" if @o.width
        
        @o.valid?
      end
      
      should "have invalid width" do
        assert_contain_error @o, :width, "can't be blank"
      end
    end
    
    # test validates width and length can be set at the same time
    context "with width and lenght are not nil" do
      setup do
        @o.width = 1000
        @o.length = 1000
        
        @o.valid?
      end
      
      should "have valid width" do
        assert_nil @o.errors.on(:width)
      end
      
      should "have valid length" do
        assert_nil @o.errors.on(:length)
      end
    end
    
    # test validates height needs width+length
    context "width width and length are nil, but height is not nil" do
      setup do
        flunk "width should be nil" if @o.width
        flunk "length should be nil" if @o.length
        
        @o.height = 1000
        
        @o.valid?
      end
      
      should "have invalid width" do
        assert_contain_error @o, :width, "can't be blank"
      end
      
      should "have invalid length" do
        assert_contain_error @o, :length, "can't be blank"
      end
    end
    
    # test validates height needs width+length
    context "width width and length are not nil, and height is not nil" do
      setup do
        @o.width = 1000
        @o.length = 1000
        @o.height = 1000
        
        @o.valid?
      end
      
      should "have valid width" do
        assert_nil @o.errors.on(:width)
      end
      
      should "have valid length" do
        assert_nil @o.errors.on(:length)
      end
      
      should "have valid height" do
        assert_nil @o.errors.on(:height)
      end
    end
    
    # test dimensions
    context "with neither width, length nor height" do
      setup do
        flunk "width should be nil" if @o.width
        flunk "length should be nil" if @o.length
        flunk "height should be nil" if @o.height
      end
      
      should "have a blank dimensions" do
        assert @o.dimensions.blank?
      end
      
      # test width, length and height are not required
      should "not be required" do
        assert_nil @o.errors.on(:width)
        assert_nil @o.errors.on(:length)
        assert_nil @o.errors.on(:height)
      end
    end
    
    # test dimensions
    context "with width equal to 1000, and length equal to 2000" do
      setup do
        @o.width = 1000
        @o.length = 2000
        
        flunk "height should be nil" if @o.height
      end
      
      should "have a well-formed dimensions" do
        assert_equal "1000 x 2000 mm", @o.dimensions
      end
    end
    
    # test dimensions
    context "with width equal to 1000, length equal to 2000 and height equal to 3000" do
      setup do
        @o.width = 1000
        @o.length = 2000
        @o.height = 3000
      end
      
      should "have a well-formed dimensions" do
        assert_equal "1000 x 2000 x 3000 mm", @o.dimensions
      end
    end
  end
  
end
