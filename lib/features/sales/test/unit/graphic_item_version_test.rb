require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'

class GraphicItemVersionTest < ActiveSupport::TestCase
  should_belong_to :graphic_item
  
  should_have_attached_file :image
  should_have_attached_file :source
    
  should_validate_attachment_presence :image  
  
  should_validate_attachment_size :image, :less_than => 10.megabytes
  
  context "A valid created graphic item version" do
    setup do
      create_default_mockup
      
      @giv = GraphicItemVersion.new(:graphic_item => Mockup.last,
                                    :image => File.new(File.join(RAILS_ROOT, "test", "fixtures", "graphic_item.jpg")),
                                    :source => File.new(File.join(RAILS_ROOT, "test", "fixtures", "order_form.pdf")))
                                    
      flunk "@giv should be created" unless @giv.save
    end
    
    for element in ["graphic_item_id", "source_file_name", "source_file_size", "source_content_type", "image_file_name", "image_file_size", "image_content_type"]   
      should "NOT be able to update #{element}" do
        @giv.send("#{element}=",nil)
        
        @giv.valid?

        assert @giv.errors.invalid?(element)
      end
    end
  end
  
  context "A new graphic item version" do
    setup do
      @giv = GraphicItemVersion.new
    end
    
    # FIXME  should_validate_attachment_content_type :image, :valid => [ 'image/jpg', 'image/png','image/jpeg'], :invalid => [ 'image/gif', 'image/ps','image/bmp']
    should "be able to add a jpg as image file" do
      @giv.image = File.new(File.join(RAILS_ROOT, "test", "fixtures", "graphic_item.jpg"))
      @giv.valid?
      
      assert !@giv.errors.invalid?(:image)
    end
    
    should "be able to add a png as image file" do
      @giv.image = File.new(File.join(RAILS_ROOT, "test", "fixtures", "image.png"))
      @giv.valid?
      
      assert !@giv.errors.invalid?(:image)
    end
    
    should "NOT be able to add a non jpg or png as image file" do
      @giv.image = File.new(File.join(RAILS_ROOT, "test", "fixtures", "order_form.pdf"))
      @giv.valid?
      
      assert @giv.errors.invalid?(:image)
    end
    
    should "NOT be able to add a jpg as source file" do
      @giv.source = File.new(File.join(RAILS_ROOT, "test", "fixtures", "graphic_item.jpg"))
      @giv.valid?
      
      assert @giv.errors.invalid?(:source)
    end
    
    should "NOT be able to add a png as source file" do
      @giv.source = File.new(File.join(RAILS_ROOT, "test", "fixtures", "image.png"))
      @giv.valid?
      
      assert @giv.errors.invalid?(:source)
    end
    
    should "be able to add a non jpg or png as image file" do
      @giv.source = File.new(File.join(RAILS_ROOT, "test", "fixtures", "order_form.pdf"))
      @giv.valid?
      
      assert !@giv.errors.invalid?(:source)
    end
  end
end
