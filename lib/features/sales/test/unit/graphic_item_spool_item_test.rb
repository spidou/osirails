require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'

class GraphicItemSpoolItemTest < ActiveSupport::TestCase
  should_belong_to :user, :graphic_item
  should_validate_presence_of :user_id, :graphic_item_id, :file_type
  
  context "A new mockup" do
    setup do
      create_default_mockup
      @gisi = GraphicItemSpoolItem.new({:user_id => User.first.id, :graphic_item_id => GraphicItem.first.id, :file_type => "image", :path => "/test/path"})
    end
    
    should "have a well-formatted user_spool_directory" do
      assert_equal @gisi.user_id.to_s, @gisi.user_spool_directory
    end
    
    should "have a well-formatted customer_name" do
      assert_equal @gisi.graphic_item.order.customer.name.gsub(" ","_"), @gisi.customer_name
    end
    
    should "have a well-formatted order_title" do
      assert_equal @gisi.graphic_item.order.title.gsub(" ","_"), @gisi.order_title
    end
    
    should "have a well-formatted graphic_item_name " do
      assert_equal @gisi.graphic_item.name_was.gsub(" ","_"), @gisi.graphic_item_name
    end
    
    should "have a well-formatted graphic_item_path" do
      assert_equal @gisi.graphic_item.send("current_#{@gisi.file_type}").path, @gisi.graphic_item_path
    end
    
    should "have a well-formatted extension" do
      assert_equal File.extname(@gisi.graphic_item_path), @gisi.graphic_item_extension
    end
  end
  
  context "A created graphic item spool item" do
    setup do
      create_default_mockup
      @gisi = GraphicItemSpoolItem.new({:user_id => User.first.id, :graphic_item_id => GraphicItem.first.id, :file_type => "image", :path => "/test/path"})
      flunk "The graphic item spool item should be created with success" unless @gisi.save
    end
  
    should "NOT be able to be updated" do
      @gisi.path = "/other/path"
      
      assert !@gisi.save
    end
    
    should "NOT be able to be copied" do
      @other = GraphicItemSpoolItem.new({:user_id => User.first.id, :graphic_item_id => GraphicItem.first.id, :file_type => "image", :path => "/another/path"})
      @other.valid?
      
      assert @other.errors.on(:graphic_item_id)
    end
  end
end
