require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'

class GraphicDocumentTest < ActiveSupport::TestCase
  should_belong_to :order, :graphic_unit_measure, :creator, :graphic_document_type
  
  should_have_many :graphic_item_versions
  
  should_validate_presence_of :name, :description
  should_validate_presence_of :order, :graphic_document_type, :graphic_unit_measure, :creator, :with_foreign_key => :default 
  
  # FIXME there is no should_validate_persistence_of :graphic_unit_measure, :reference, :graphic_document_type, :order,
  # For the moment, persistent attributes are tested manually, before an eventually future validates_persistence_of shoulda macro
  
  context "A new graphic_document" do
    setup do
      @graphic_document = GraphicDocument.new
      @graphic_document.valid?
    end
    
    context ", when adding an image," do
      setup do
        flunk "The graphic item version attributes should be assigned to continue" unless @graphic_document.graphic_item_version_attributes=( {:image => File.new(File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg"))} )
        @version = @graphic_document.graphic_item_versions.last
      end
      
      should "set 'should_add_version' flag to true" do
        assert_equal @graphic_document.should_add_version, true
      end
      
      should "remain its old_graphic_item_version at nil" do
        assert_nil @graphic_document.old_graphic_item_version
      end
      
      should "build a valid graphic item" do
        assert @version.valid?
      end
      
      should "build a graphic item version which is a new record" do
        assert @version.new_record?
      end
      
      should "set the new_graphic_item_version to the built graphic item version" do
        assert_equal @graphic_document.new_graphic_item_version, @version
      end
    end 
    
    context ", when adding an image and a source," do
      setup do
        flunk "The graphic item version attributes should be assigned to continue" unless @graphic_document.graphic_item_version_attributes=({ :image  => File.new(File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg")),
                                                                                                                                     :source => File.new(File.join(RAILS_ROOT, "test", "fixtures", "graphic_item.jpg"))
                                                                                                                                   })
        @version = @graphic_document.graphic_item_versions.last
      end
      
      should "set 'should_add_version' flag to true" do
        assert_equal @graphic_document.should_add_version, true
      end
      
      should "remain its old_graphic_item_version at nil" do
        assert_nil @graphic_document.old_graphic_item_version
      end
      
      should "build a valid graphic item" do
        assert @version.valid?
      end
      
      should "build a graphic item version which is a new record" do
        assert @version.new_record?
      end
      
      should "set the new_graphic_item_version to the built graphic item version" do
        assert_equal @graphic_document.new_graphic_item_version, @version
      end
    end
    
    context ", when adding only a source," do
      setup do
        flunk "The graphic item version attributes should NOT be assigned to continue" unless @graphic_document.graphic_item_version_attributes=( {:source => File.new(File.join(RAILS_ROOT, "test", "fixtures", "graphic_item.jpg"))} )
        @version = @graphic_document.graphic_item_versions.last
      end
      
      should "set 'should_add_version' flag to true" do
        assert_equal @graphic_document.should_add_version, true
      end
      
      should "remain its old_graphic_item_version at nil" do
        assert_nil @graphic_document.old_graphic_item_version
      end
      
      should "NOT build a valid graphic item" do
        assert !@version.valid?
      end
      
      should "build a graphic item version which is a new record" do
        assert @version.new_record?
      end
      
      should "set the new_graphic_item_version to the built graphic item version" do
        assert_equal @graphic_document.new_graphic_item_version, @version
      end
    end 
    
    context ", without any image or source" do
      should "NOT be valid on the new_graphic_item_version" do
        assert @graphic_document.errors.invalid?(:new_graphic_item_version)
      end
    end
  end
  
  context "A valid created graphic_document" do
    setup do 
      @previous_graphic_document = create_default_graphic_document
      @graphic_document = create_default_graphic_document
      @version = @graphic_document.current_version
    end
    
    subject { @graphic_document }
    
    should_validate_uniqueness_of :reference
    
    should "have saved a valid graphic item version" do
      assert @version.is_a?(GraphicItemVersion)
    end
    
    should "have saved a valid graphic item version with its id as graphic item id" do
      assert @version.graphic_item_id = @graphic_document.id
    end
    
    should "have saved a valid graphic item version which is not a new record" do
      assert !@version.new_record?
    end
    
    should "have a generated reference equal to previous graphic_document reference plus one" do
      assert_equal @graphic_document.reference, @previous_graphic_document.reference + 1
    end
    
    should "be valid without adding any source or image" do
      assert @graphic_document.valid?      
    end
    
    should "be able to be cancelled" do
      assert @graphic_document.can_be_cancelled?
    end
    
    for element in ["reference","graphic_unit_measure_id","graphic_document_type_id","order_id"]   
      should "NOT be able to update #{element}" do
        @graphic_document.send("#{element}=",nil)
        
        @graphic_document.valid?

        assert @graphic_document.errors.invalid?(element)
      end
    end
    
    context ", after having add a source without its image," do
      setup do
        @graphic_document.graphic_item_version_attributes=( {:source => File.new(File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg"))} )
        @graphic_document.valid?
      end
      
      should "not be valid and generate an error on the new_graphic_item_version" do
        assert @graphic_document.errors.invalid?(:new_graphic_item_version)
      end
    end
    
    context ", after having add a new image," do
      setup do
        @old_version = @graphic_document.current_version
        @graphic_document.graphic_item_version_attributes=( {:image => File.new(File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg"))} )
        flunk "@graphic_document should be saved to continue > #{@graphic_document.errors.full_messages.join(', ')}" unless @graphic_document.save
        flunk "@graphic_document.current_version should not be @old_version to continue" unless @graphic_document.current_version != @old_version
      end
      
      should "have saved a valid graphic item version" do
        assert @version.is_a?(GraphicItemVersion)
      end
      
      should "have saved a valid graphic item version with its id as graphic item id" do
        assert @version.graphic_item_id = @graphic_document.id
      end
      
      should "have saved a valid graphic item version which is not a new record" do
        assert !@version.new_record?
      end            
      
      should "have changed its current image" do
        assert_equal @graphic_document.current_image, @graphic_document.current_version.image
      end
      
      should "have changed its current source" do
        assert_equal @graphic_document.current_source, @graphic_document.current_version.source
      end
    end
    
    context ", after having add both new image and new source," do
      setup do
        @old_version = @graphic_document.current_version
        @graphic_document.graphic_item_version_attributes=( {:image => File.new(File.join(RAILS_ROOT, "test", "fixtures", "graphic_item.jpg")), :source => File.new(File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg")) } )
        flunk "@graphic_document should be saved to continue > #{@graphic_document.errors.full_messages.join(', ')}" unless @graphic_document.save     
        flunk "@graphic_document.current_version should not be @old_version to continue" unless @graphic_document.current_version != @old_version
      end
      
      should "have saved a valid graphic item version" do
        assert @version.is_a?(GraphicItemVersion)
      end
      
      should "have saved a valid graphic item version with its id as graphic item id" do
        assert @version.graphic_item_id = @graphic_document.id
      end
      
      should "have saved a valid graphic item version which is not a new record" do
        assert !@version.new_record?
      end
      
      should "have changed its current image" do
        assert_equal @graphic_document.current_image, @graphic_document.current_version.image
      end
      
      should "have changed its current source" do
        assert_equal @graphic_document.current_source, @graphic_document.current_version.source
      end
    end
    
    context ", with a second version," do
      setup do
        @old_version = @graphic_document.current_version
        @graphic_document.graphic_item_version_attributes=( {:image => File.new(File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg")) } )
        flunk "@graphic_document should be saved to continue > #{@graphic_document.errors.full_messages.join(', ')}" unless @graphic_document.save      

        flunk "@graphic_document.current_version should not be @old_version to continue" unless @graphic_document.current_version != @old_version
      end
    
      context ", after having updated its current version," do
        setup do
          @graphic_document.current_version = @graphic_document.graphic_item_versions.first.id
          flunk "@graphic_document should be saved to continue > #{@graphic_document.errors.full_messages.join(', ')}" unless @graphic_document.save
        end
        
        should "have changed its current image" do
          assert_equal @graphic_document.current_image, @graphic_document.current_version.image
        end
        
        should "have changed its current source" do
          assert_equal @graphic_document.current_source, @graphic_document.current_version.source
        end
      end
      
      context ", after having both updated current_version and add an image," do
        setup do
          @graphic_document.graphic_item_version_attributes=( {:image => File.new(File.join(RAILS_ROOT, "test", "fixtures", "graphic_item.jpg")) } )
          flunk "@graphic_document should be saved to continue  > #{@graphic_document.errors.full_messages.join(', ')}" unless @graphic_document.save
          @graphic_document.graphic_item_version_attributes=( {:image => File.new(File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg")) } )
          @graphic_document.current_version = @graphic_document.graphic_item_versions.first.id
          flunk "@graphic_document should NOT be saved to continue" if @graphic_document.save
        end
        
        should "generate an error" do
          assert @graphic_document.errors.invalid?(:graphic_item_version)
        end
      end      
    end
    
    context ", after having cancel," do
      setup do
        flunk "@graphic_document should have cancel to continue" unless @graphic_document.cancel
      end
      
      should "be cancelled" do
        assert @graphic_document.cancelled?
      end
      
      should "NOT be able to be cancelled" do
        assert !@graphic_document.can_be_cancelled?
        assert !@graphic_document.cancel
      end
    end
  end
end
