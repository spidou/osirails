require File.dirname(__FILE__) + '/../sales_test'

class QuoteItemTest < ActiveSupport::TestCase
  should_belong_to :quote, :quotable
  
  should_validate_presence_of :name
  
  should_journalize :attributes        => [:name, :description, :dimensions, :unit_price, :prizegiving,
                                           :quantity, :vat, :position, :pro_rata_billing]#,
                    #:identifier_method =>  Proc.new{ |i| "#{i.designation} (x #{i.quantity})" }
  
  #TODO QuoteItemTest need to be reviewed since we have added support of service_delivery on quotes (some methods are not tested)
  
  context 'A "free" quote item' do
    setup do
      @quote_item = QuoteItem.new
    end
    
    should "NOT have a reference_object" do
        assert_nil @quote_item.reference_object
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
    
    should "NOT have a default name" do
      assert_nil @quote_item.name
    end
    
    should "NOT have a default description" do
      assert_nil @quote_item.description
    end
    
    should "NOT have a default vat" do
      assert_nil @quote_item.vat
    end
    
    context "without name" do
      setup do
        flunk "@quote_item should have no name" if @quote_item.name
      end
      
      should "NOT have a designation" do
        assert_nil @quote_item.designation
      end
    end
    
    context "with a name" do
      setup do
        @quote_item.name = "My Product 1"
      end
      
      should "have a valid designation" do
        assert_equal "My Product 1", @quote_item.designation
      end
      
      context "and with dimensions" do
        setup do
          @quote_item.dimensions = "1000x2000"
        end
        
        should "have a valid designation" do
          assert_equal "My Product 1", @quote_item.designation # 'dimensions' is not taken in account because a free_item is not supposed to have 'dimensions'
        end
      end
    end
  end
  
  context 'A "product" quote item' do
    setup do
      @quote_item = QuoteItem.new
    end
    
    context "without quotable" do
      setup do
        flunk "@quote_item should NOT have a quotable" if @quote_item.quotable
      end
      
      #TODO
    end
    
    context "associated to a quotable" do
      setup do
        @quote_item = QuoteItem.new(:quotable_id => products(:first_end_product).id, :quotable_type => 'EndProduct')
        flunk "@quote_item.quotable should have a product_reference" unless @quote_item.quotable.product_reference
        
        @product_reference = @quote_item.quotable.product_reference
        
        flunk "@product_reference.name should be equal to <\"First Product Reference\">, but was <#{@product_reference.name.inspect}>" unless @product_reference.name == "First Product Reference"
        flunk "@product_reference.description should be equal to <\"This is my first product reference\">, but was <#{@product_reference.description.inspect}>" unless @product_reference.description == "This is my first product reference"
        flunk "@product_reference.vat should be equal to <5.5>, but was <\"#{@product_reference.vat.inspect}\">" unless @product_reference.vat == 5.5
        
        flunk "@product_reference.designation should be equal to <\"Parent category Child category First Product Reference\">, but was <#{@product_reference.designation.inspect}>" unless @product_reference.designation == "Parent category Child category First Product Reference"
      end
      
      subject{ @quote_item }
      
      should_validate_numericality_of :unit_price, :prizegiving, :vat, :quantity
      
      should "have a reference_object" do
        assert_equal @product_reference, @quote_item.reference_object
      end
      
      should 'NOT be "free_item"' do
        assert !@quote_item.free_item?
      end
      
      should 'have an original_name' do
        expected_value = "Parent category Child category First Product Reference" # <=> product_reference.designation
        assert_equal expected_value, @quote_item.original_name
      end
      
      should 'have an original_description' do
        assert_equal "This is my first product reference", @quote_item.original_description
      end
      
      should 'have an original_vat' do
        assert_equal 5.5, @quote_item.original_vat
      end
      
      should "have a default name" do
        expected_value = "Parent category Child category First Product Reference" # <=> product_reference.designation
        assert_equal expected_value, @quote_item.name
      end
      
      should "have a default description" do
        assert_equal "This is my first product reference", @quote_item.description
      end
      
      should "NOT have a default vat" do
        assert_equal 5.5, @quote_item.original_vat
      end
      
      should "have a valid designation" do
        expected_value = "Parent category Child category First Product Reference"
        assert_equal expected_value, @quote_item.designation
      end
      
      context ", and with dimensions" do
        setup do
          @quote_item.dimensions = "1000x2000"
        end
        
        should "have a valid designation" do
          expected_value = "Parent category Child category First Product Reference (1000x2000)" # <=> name (dimensions)
          assert_equal expected_value, @quote_item.designation
        end
      end
    end
  end
  
  context "A valid and saved quote_item" do
    setup do
      quote = create_quote_for(create_default_order)
      @product = quote.quote_items.first
    end
    
    include ProductBaseTest
  end
end
