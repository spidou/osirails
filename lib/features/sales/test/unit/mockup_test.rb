require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'

class MockupTest < ActiveSupport::TestCase
  should_belong_to :order, :graphic_unit_measure, :creator, :mockup_type, :product
  
  should_have_many :graphic_item_versions
  
  should_validate_presence_of :name, :description
  should_validate_presence_of :order, :mockup_type, :product, :graphic_unit_measure, :creator, :with_foreign_key => :default 
  
  # FIXME there is no should_validate_persistence_of :graphic_unit_measure, :reference, :mockup_type, :product, :order
  # For the moment, persistent attributes are tested manually, before an eventually future validates_persistence_of shoulda macro
  
  context "A new mockup" do
    setup do
      @mockup = Mockup.new
      @mockup.valid?
    end
    
    should "NOT belong to a product include in another order products list" do      
      @in_base_mockup = create_default_mockup
      @mockup.order = create_default_order  
      
      @mockup.product = @in_base_mockup.order.products.first
      
      @mockup.valid?
      
      assert @mockup.errors.invalid?(:product)
    end    

    should "belong to a product include in its order products list" do      
      @mockup.order = create_default_order     
      @mockup.product = create_valid_product_for(@mockup.order)
      
      @mockup.valid?
      assert !@mockup.errors.invalid?(:product)
    end
    
    context ", when adding an image," do
      setup do
        flunk "The graphic item version attributes should be assigned to continue" unless @mockup.graphic_item_version_attributes=( {:image => File.new(File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg"))} )
        @version = @mockup.graphic_item_versions.last
      end
      
      should "set 'should_add_version' flag to true" do
        assert_equal @mockup.should_add_version, true
      end
      
      should "remain its old_graphic_item_version at nil" do
        assert_nil @mockup.old_graphic_item_version
      end
      
      should "build a valid graphic item" do
        assert @version.valid?
      end
      
      should "build a graphic item version which is a new record" do
        assert @version.new_record?
      end
      
      should "set the new_graphic_item_version to the built graphic item version" do
        assert_equal @mockup.new_graphic_item_version, @version
      end
    end 
    
    context ", when adding an image and a source," do
      setup do
        flunk "The graphic item version attributes should be assigned to continue" unless @mockup.graphic_item_version_attributes=({ :image  => File.new(File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg")),
                                                                                                                                     :source => File.new(File.join(RAILS_ROOT, "test", "fixtures", "graphic_item.jpg"))
                                                                                                                                   })
        @version = @mockup.graphic_item_versions.last
      end
      
      should "set 'should_add_version' flag to true" do
        assert_equal @mockup.should_add_version, true
      end
      
      should "remain its old_graphic_item_version at nil" do
        assert_nil @mockup.old_graphic_item_version
      end
      
      should "build a valid graphic item" do
        assert @version.valid?
      end
      
      should "build a graphic item version which is a new record" do
        assert @version.new_record?
      end
      
      should "set the new_graphic_item_version to the built graphic item version" do
        assert_equal @mockup.new_graphic_item_version, @version
      end
    end
    
    context ", when adding only a source," do
      setup do
        flunk "The graphic item version attributes should NOT be assigned to continue" unless @mockup.graphic_item_version_attributes=( {:source => File.new(File.join(RAILS_ROOT, "test", "fixtures", "graphic_item.jpg"))} )
        @version = @mockup.graphic_item_versions.last
      end
      
      should "set 'should_add_version' flag to true" do
        assert_equal @mockup.should_add_version, true
      end
      
      should "remain its old_graphic_item_version at nil" do
        assert_nil @mockup.old_graphic_item_version
      end
      
      should "NOT build a valid graphic item" do
        assert !@version.valid?
      end
      
      should "build a graphic item version which is a new record" do
        assert @version.new_record?
      end
      
      should "set the new_graphic_item_version to the built graphic item version" do
        assert_equal @mockup.new_graphic_item_version, @version
      end
    end 
    
    context ", without any image or source" do
      should "NOT be valid on the new_graphic_item_version" do
        assert @mockup.errors.invalid?(:new_graphic_item_version)
      end
    end
  end
  
  context "A valid created mockup" do
    setup do 
      @previous_mockup = create_default_mockup
      @mockup = create_default_mockup
      @version = @mockup.current_version
    end
    
    subject { @mockup }
    
    should_validate_uniqueness_of :reference
    
    should "have saved a valid graphic item version" do
      assert @version.is_a?(GraphicItemVersion)
    end
    
    should "have saved a valid graphic item version with its id as graphic item id" do
      assert @version.graphic_item_id = @mockup.id
    end
    
    should "have saved a valid graphic item version which is not a new record" do
      assert !@version.new_record?
    end
    
    should "have a generated reference equal to previous mockup reference plus one" do
      assert_equal @mockup.reference, @previous_mockup.reference + 1
    end
    
    should "be valid without adding any source or image" do
      assert @mockup.valid?      
    end
    
    should "be able to be cancelled" do
      assert @mockup.can_be_cancelled?
    end
    
    for element in ["reference","graphic_unit_measure_id","mockup_type_id","product_id","order_id"]   
      should "NOT be able to update #{element}" do
        @mockup.send("#{element}=",nil)
        
        @mockup.valid?

        assert @mockup.errors.invalid?(element)
      end
    end
    
    context ", after having add a source without its image," do
      setup do
        @mockup.graphic_item_version_attributes=( {:source => File.new(File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg"))} )
        @mockup.valid?
      end
      
      should "not be valid and generate an error on the new_graphic_item_version" do
        assert @mockup.errors.invalid?(:new_graphic_item_version)
      end
    end
    
    context ", after having add a new image," do
      setup do
        @old_version = @mockup.current_version
        @mockup.graphic_item_version_attributes=( {:image => File.new(File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg"))} )
        flunk "@mockup should be saved to continue > #{@mockup.errors.full_messages.join(', ')}" unless @mockup.save
        flunk "@mockup.current_version should not be @old_version to continue" unless @mockup.current_version != @old_version
      end
      
      should "have saved a valid graphic item version" do
        assert @version.is_a?(GraphicItemVersion)
      end
      
      should "have saved a valid graphic item version with its id as graphic item id" do
        assert @version.graphic_item_id = @mockup.id
      end
      
      should "have saved a valid graphic item version which is not a new record" do
        assert !@version.new_record?
      end            
      
      should "have changed its current image" do
        assert_equal @mockup.current_image, @mockup.current_version.image
      end
      
      should "have changed its current source" do
        assert_equal @mockup.current_source, @mockup.current_version.source
      end
    end
    
    context ", after having add both new image and new source," do
      setup do
        @old_version = @mockup.current_version
        @mockup.graphic_item_version_attributes=( {:image => File.new(File.join(RAILS_ROOT, "test", "fixtures", "graphic_item.jpg")), :source => File.new(File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg")) } )
        flunk "@mockup should be saved to continue > #{@mockup.errors.full_messages.join(', ')}" unless @mockup.save     
        flunk "@mockup.current_version should not be @old_version to continue" unless @mockup.current_version != @old_version
      end
      
      should "have saved a valid graphic item version" do
        assert @version.is_a?(GraphicItemVersion)
      end
      
      should "have saved a valid graphic item version with its id as graphic item id" do
        assert @version.graphic_item_id = @mockup.id
      end
      
      should "have saved a valid graphic item version which is not a new record" do
        assert !@version.new_record?
      end
      
      should "have changed its current image" do
        assert_equal @mockup.current_image, @mockup.current_version.image
      end
      
      should "have changed its current source" do
        assert_equal @mockup.current_source, @mockup.current_version.source
      end
    end
    
    context ", with a second version," do
      setup do
        @old_version = @mockup.current_version
        @mockup.graphic_item_version_attributes=( {:image => File.new(File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg")) } )
        flunk "@mockup should be saved to continue > #{@mockup.errors.full_messages.join(', ')}" unless @mockup.save      

        flunk "@mockup.current_version should not be @old_version to continue" unless @mockup.current_version != @old_version
      end
    
      context ", after having updated its current version," do
        setup do
          @mockup.current_version = @mockup.graphic_item_versions.first.id
          flunk "@mockup should be saved to continue > #{@mockup.errors.full_messages.join(', ')}" unless @mockup.save
        end
        
        should "have changed its current image" do
          assert_equal @mockup.current_image, @mockup.current_version.image
        end
        
        should "have changed its current source" do
          assert_equal @mockup.current_source, @mockup.current_version.source
        end
      end
      
      context ", after having both updated current_version and add an image," do
        setup do
          @mockup.graphic_item_version_attributes=( {:image => File.new(File.join(RAILS_ROOT, "test", "fixtures", "graphic_item.jpg")) } )
          flunk "@mockup should be saved to continue  > #{@mockup.errors.full_messages.join(', ')}" unless @mockup.save
          @mockup.graphic_item_version_attributes=( {:image => File.new(File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg")) } )
          @mockup.current_version = @mockup.graphic_item_versions.first.id
          flunk "@mockup should NOT be saved to continue" if @mockup.save
        end
        
        should "generate an error" do
          assert @mockup.errors.invalid?(:graphic_item_version)
        end
      end      
    end
    
    context ", after having cancel," do
      setup do
        flunk "@mockup should have cancel to continue" unless @mockup.cancel
      end
      
      should "be cancelled" do
        assert @mockup.cancelled?
      end
      
      should "NOT be able to be cancelled" do
        assert !@mockup.can_be_cancelled?
        assert !@mockup.cancel
      end
    end
  end
end
