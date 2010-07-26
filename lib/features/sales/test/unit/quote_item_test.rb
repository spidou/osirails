require File.dirname(__FILE__) + '/../sales_test'

class QuoteItemTest < ActiveSupport::TestCase
  include ProductBaseTest
  
  should_belong_to :quote, :end_product
  
  should_have_many :delivery_note_items, :dependent => :nullify
  should_have_many :delivery_notes,      :through   => :delivery_note_items
  
  should_validate_presence_of :name
  
  context 'A "free" quote item' do
    setup do
      @quote_item = QuoteItem.new
    end
    
    should 'be "free_item"' do
      assert @quote_item.free_item?
    end
    
    should 'NOT have an original_name' do
      assert_nil @quote_item.original_name
    end
    
    should 'NOT have an original_description' do
      assert_nil @quote_item.original_description
    end
    
    should 'NOT have an original_vat' do
      assert_nil @quote_item.original_vat
    end
    
    should 'have a designation' do
      assert_equal @quote_item.name, @quote_item.designation
    end
  end
  
  context 'A "product" quote item' do
    setup do
      @quote_item = QuoteItem.new(:end_product_id => EndProduct.first.id)
      flunk "@quote_item.end_product should have product_reference" unless @quote_item.end_product.product_reference
    end
    
    subject{ @quote_item }
    
    should_validate_numericality_of :unit_price, :prizegiving, :vat, :quantity
    
    should 'NOT be "free_item"' do
      assert !@quote_item.free_item?
    end
    
    should 'have an original_name' do
      assert_equal @quote_item.end_product.product_reference.name, @quote_item.original_name
    end
    
    should 'have an original_description' do
      assert_equal @quote_item.end_product.product_reference.description, @quote_item.original_description
    end
    
    should 'have an original_vat' do
      assert_equal @quote_item.end_product.product_reference.vat, @quote_item.original_vat
    end
    
    should 'have a designation' do
      assert_equal @quote_item.end_product.designation, @quote_item.designation
    end
  end
end
