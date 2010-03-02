require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'

class GraphicDocumentTest < ActiveSupport::TestCase
  should_belong_to :order, :graphic_unit_measure, :creator, :graphic_document_type
  
  should_have_many :graphic_item_versions
  
  # FIXME there is no should_validate_persistence_of :graphic_unit_measure, :reference, :graphic_document_type, :order,
  # For the moment, persistent attributes are tested manually, before an eventually future validates_persistence_of shoulda macro
  
  context "A new graphic_document" do
    setup do
      @order = create_default_order
      @graphic_document = @order.graphic_documents.build
      @graphic_document.valid?
    end
    
    subject{ @graphic_document }
    
    should_validate_presence_of :name, :description
    should_validate_presence_of :order, :graphic_document_type, :graphic_unit_measure, :creator, :with_foreign_key => :default 
    
    context ", when adding an image," do
      setup do
        flunk "The graphic item version attributes should be assigned" unless @graphic_document.graphic_item_version_attributes=( {:image => File.new(File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg"))} )
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
        flunk "The graphic item version attributes should be assigned" unless @graphic_document.graphic_item_version_attributes=({ :image  => File.new(File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg")),
                                                                                                                                   :source => File.new(File.join(RAILS_ROOT, "test", "fixtures", "order_form.pdf")) })
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
        flunk "The graphic item version attributes should NOT be assigned" unless @graphic_document.graphic_item_version_attributes=( {:source => File.new(File.join(RAILS_ROOT, "test", "fixtures", "order_form.pdf"))} )
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
      @graphic_document = create_default_graphic_document
      @version = @graphic_document.current_version
    end
    
    subject { @graphic_document }
    
    should "have saved a valid graphic item version" do
      assert @version.is_a?(GraphicItemVersion)
    end
    
    should "have saved a valid graphic item version with its id as graphic item id" do
      assert @version.graphic_item_id = @graphic_document.id
    end
    
    should "have saved a valid graphic item version which is not a new record" do
      assert !@version.new_record?
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

        assert @graphic_document.errors.invalid?(element.to_sym)
      end
    end
      
    context ", before an addition of its image or source in an user spool" do
      should "be able to update its name" do
        @graphic_document.name = "Can I change my name ?"
        @graphic_document.valid?
        
        assert !@graphic_document.errors.invalid?(:name)
      end
    end
    
    context ", after an adddition of its image in an user spool" do
      setup do
        @graphic_document.add_to_graphic_item_spool("image", User.first)
      end
    
      should "NOT be able to update its name" do
        @graphic_document.name = "Can I change my name ?"
        @graphic_document.valid?
        
        assert @graphic_document.errors.invalid?(:name)
      end
    end
    
    context ", after an adddition of its source in an user spool" do
      setup do
        @graphic_document.add_to_graphic_item_spool("source", User.first)
      end
    
      should "NOT be able to update its name" do
        @graphic_document.name = "Can I change my name ?"
        @graphic_document.valid?
        
        assert @graphic_document.errors.invalid?(:name)
      end
    end
    
    context ", after having add a source without its image," do
      setup do
        @graphic_document.graphic_item_version_attributes=( {:source => File.new(File.join(RAILS_ROOT, "test", "fixtures", "subcontractor_request.pdf"))} )
        @graphic_document.valid?
      end
      
      should "NOT be valid and generate an error on the new_graphic_item_version" do
        assert @graphic_document.errors.invalid?(:new_graphic_item_version)
      end
    end
    
    context ", after having add a new image," do
      setup do
        @old_version = @graphic_document.current_version
        @graphic_document.graphic_item_version_attributes=( {:image => File.new(File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg"))} )
        flunk "@graphic_document should be saved > #{@graphic_document.errors.full_messages.join(', ')}" unless @graphic_document.save
        flunk "@graphic_document.current_version should not be @old_version" unless @graphic_document.current_version != @old_version
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
      
      should "have destroyed its items in users spool" do
        assert GraphicItemSpoolItem.find(:all,:conditions => ["graphic_item_id = ?", @graphic_document.id]).empty?
      end
    end
    
    context ", after having add both new image and new source," do
      setup do
        @old_version = @graphic_document.current_version
        @graphic_document.graphic_item_version_attributes=( {:image => File.new(File.join(RAILS_ROOT, "test", "fixtures", "graphic_item.jpg")), :source => File.new(File.join(RAILS_ROOT, "test", "fixtures", "subcontractor_request.pdf")) } )
        flunk "@graphic_document should be saved > #{@graphic_document.errors.full_messages.join(', ')}" unless @graphic_document.save     
        flunk "@graphic_document.current_version should not be @old_version" unless @graphic_document.current_version != @old_version
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
      
      should "have destroyed its items in users spool" do
        assert GraphicItemSpoolItem.find(:all,:conditions => ["graphic_item_id = ?", @graphic_document.id]).empty?
      end
    end
    
    context ", with a second version," do
      setup do
        @old_version = @graphic_document.current_version
        @graphic_document.graphic_item_version_attributes=( {:image => File.new(File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg")) } )
        flunk "@graphic_document should be saved > #{@graphic_document.errors.full_messages.join(', ')}" unless @graphic_document.save      

        flunk "@graphic_document.current_version should not be @old_version" unless @graphic_document.current_version != @old_version
      end
    
      context ", after having updated its current version," do
        setup do
          @graphic_document.current_version = @graphic_document.graphic_item_versions.first.id
          flunk "@graphic_document should be saved > #{@graphic_document.errors.full_messages.join(', ')}" unless @graphic_document.save
        end
        
        should "have changed its current image" do
          assert_equal @graphic_document.current_image, @graphic_document.current_version.image
        end
        
        should "have changed its current source" do
          assert_equal @graphic_document.current_source, @graphic_document.current_version.source
        end
        
        should "have destroyed its items in users spool" do
          assert GraphicItemSpoolItem.find(:all,:conditions => ["graphic_item_id = ?", @graphic_document.id]).empty?
        end
      end
      
      context ", after having both updated current_version and add an image," do
        setup do
          @graphic_document.graphic_item_version_attributes=( {:image => File.new(File.join(RAILS_ROOT, "test", "fixtures", "graphic_item.jpg")) } )
          flunk "@graphic_document should be saved  > #{@graphic_document.errors.full_messages.join(', ')}" unless @graphic_document.save
          @graphic_document.graphic_item_version_attributes=( {:image => File.new(File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg")) } )
          @graphic_document.current_version = @graphic_document.graphic_item_versions.first.id
          flunk "@graphic_document should NOT be saved" if @graphic_document.save
        end
        
        should "generate an error" do
          assert @graphic_document.errors.invalid?(:graphic_item_version)
        end
      end      
    end
    
    context ", after having cancel," do
      setup do
        flunk "@graphic_document should have cancel" unless @graphic_document.cancel
      end
      
      should "be cancelled" do
        assert @graphic_document.cancelled?
      end
      
      should "NOT be able to be cancelled" do
        assert !@graphic_document.can_be_cancelled?
        assert !@graphic_document.cancel
      end
    end
    
    should "NOT be able to remove its current image from an user graphic item spool" do
      assert !@graphic_document.remove_from_graphic_item_spool("image",User.first)
    end
    
    should "NOT be able to remove its current source from an user graphic item spool" do
      assert !@graphic_document.remove_from_graphic_item_spool("source",User.first)
    end
    
    should "NOT be able to add a non paperclip object to an user graphic item spool" do
      assert !@graphic_document.add_to_graphic_item_spool("other",User.first)
    end
    
    context ", after having add its current image to an user graphic item spool" do
      setup do
        flunk "@graphic_document.current_image should be added to the user graphic item spool" unless @graphic_document.add_to_graphic_item_spool("image",User.first)
      end
      
      should "have its current image in the user graphic item spool" do
        assert @graphic_document.is_in_user_spool("image",User.first)
      end
      
      should "have its current image in spool" do
        assert @graphic_document.is_in_spool("image")
      end
      
      should "be able to remove its current image from the user graphic item spool" do
        flunk "@graphic_document.current_image should be removed from the user graphic item spool" unless @graphic_document.remove_from_graphic_item_spool("image",User.first)
        assert !@graphic_document.is_in_user_spool("image",User.first)
      end
      
      should "have a corresponding file in its assets spool directory" do
        @gisi = GraphicItemSpoolItem.find(:first, :conditions => ["user_id = ? AND graphic_item_id = ? AND file_type = ?",User.first.id,@graphic_document.id,"image"])
        assert File.exists?(@gisi.path)
      end
      
      should "have a spool item corresponding to the id returned by the spool_item_id method" do
        @gisi = GraphicItemSpoolItem.find(:first, :conditions => ["user_id = ? AND graphic_item_id = ? AND file_type = ?",User.first.id,@graphic_document.id,"image"])
        assert_equal @gisi.id, @graphic_document.spool_item_id("image",User.first)
      end
    end
    
    context ", after having add its current source to an user graphic item spool" do
      setup do
        flunk "@graphic_document.current_source should be added to the user graphic item spool" unless @graphic_document.add_to_graphic_item_spool("source",User.first)
      end
      
      should "have its current source in the user graphic item spool" do
        assert @graphic_document.is_in_user_spool("source",User.first)  
      end
      
      should "have its current image in spool" do
        assert @graphic_document.is_in_spool("source")
      end
      
      should "be able to remove its current source from the user graphic item spool" do
        flunk "@graphic_document.current_source should be removed from the user graphic item spool" unless @graphic_document.remove_from_graphic_item_spool("source",User.first)
        assert !@graphic_document.is_in_user_spool("source",User.first)
      end
      
      should "have a corresponding file in its assets spool directory" do
        @gisi = GraphicItemSpoolItem.find(:first, :conditions => ["user_id = ? AND graphic_item_id = ? AND file_type = ?",User.first.id,@graphic_document.id,"source"])
        assert File.exists?(@gisi.path)
      end
      
      should "have a spool item corresponding to the id returned by the spool_item_id method" do
        @gisi = GraphicItemSpoolItem.find(:first, :conditions => ["user_id = ? AND graphic_item_id = ? AND file_type = ?",User.first.id,@graphic_document.id,"source"])
        assert_equal @gisi.id, @graphic_document.spool_item_id("source",User.first)
      end
    end
    
    context ", after having remove its current image to an user graphic item spool" do
      setup do
        flunk "@graphic_document.current_image should be added to the user graphic item spool" unless @graphic_document.add_to_graphic_item_spool("image",User.first)
        @gisi_path = GraphicItemSpoolItem.find(:first, :conditions => ["user_id = ? AND graphic_item_id = ? AND file_type = ?",User.first.id,@graphic_document.id,"image"]).path
        flunk "@graphic_document.current_image should be added to the user graphic item spool" unless @graphic_document.remove_from_graphic_item_spool("image",User.first)
      end
      
      should "NOT have its current image in the user graphic item spool" do
        assert !@graphic_document.is_in_user_spool("image",User.first)
      end
      
      should "NOT be able to remove its current image from the user graphic item spool" do
        assert !@graphic_document.remove_from_graphic_item_spool("image",User.first)
      end
      
      should "be able to add its current image from the user graphic item spool" do
        flunk "@graphic_document.current_image should be added to the user graphic item spool" unless @graphic_document.add_to_graphic_item_spool("image",User.first)
        assert @graphic_document.is_in_user_spool("image",User.first)
      end
      
      should "NOT have a corresponding file in its assets spool directory" do
        assert !File.exists?(@gisi_path)
      end
      
      should "NOT have any spool item for its image" do
        assert_nil @graphic_document.spool_item_id("image",User.first)
      end
    end
    
    context ", after having remove its current source to an user graphic item spool" do
      setup do
        flunk "@graphic_document.current_source should be added to the user graphic item spool" unless @graphic_document.add_to_graphic_item_spool("source",User.first)
        @gisi_path = GraphicItemSpoolItem.find(:first, :conditions => ["user_id = ? AND graphic_item_id = ? AND file_type = ?",User.first.id,@graphic_document.id,"source"]).path
        flunk "@graphic_document.current_source should be removed from the user graphic item spool" unless @graphic_document.remove_from_graphic_item_spool("source",User.first)
      end
      
      should "NOT have its current source in the user graphic item spool" do
        assert !@graphic_document.is_in_user_spool("source",User.first)
      end
      
      should "NOT be able to remove its current source from the user graphic item spool" do
        assert !@graphic_document.remove_from_graphic_item_spool("source",User.first)
      end
      
      should "be able to add its current source from the user graphic item spool" do
        flunk "@graphic_document.current_source should be added to the user graphic item spool" unless @graphic_document.add_to_graphic_item_spool("source",User.first)
        assert @graphic_document.is_in_user_spool("source",User.first)
      end
      
      should "NOT have a corresponding file in its assets spool directory" do
        assert !File.exists?(@gisi_path)
      end
      
      should "NOT have any spool item for its source" do
        assert_nil @graphic_document.spool_item_id("source",User.first)
      end
    end
    
    context "after being destroyed" do
      setup do
        @graphic_document.add_to_graphic_item_spool("image",User.first)
        @graphic_document.add_to_graphic_item_spool("image",User.last)
        @destroyed_graphic_docuemnt_id = @graphic_document.id
        flunk "@graphic_document should be destroyed" unless @graphic_document.destroy
      end
    
      should "destroy all its versions at the same time" do
        assert GraphicItemVersion.find(:all,:conditions => ["graphic_item_id = ?", @destroyed_graphic_docuemnt_id]).empty?
      end
      
      should "destroy its image in users spool at the same time" do
        assert GraphicItemSpoolItem.find(:all,:conditions => ["graphic_item_id = ?", @destroyed_graphic_docuemnt_id]).empty?
      end
    end
  end
  
  context "generate a reference" do
    setup do
      @reference_owner       = create_default_graphic_document
      @other_reference_owner = create_default_graphic_document
    end
    
    include HasReferenceTest
  end
end
