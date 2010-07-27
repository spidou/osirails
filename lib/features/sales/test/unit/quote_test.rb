require File.dirname(__FILE__) + '/../sales_test'

class QuoteTest < ActiveSupport::TestCase
  #FIXME that test file should not be so complicated and complex (too much if..else..end, etc.)
  
  #TODO test has_permissions :as_business_object
  #TODO test has_address     :bill_to_address
  #TODO test has_address     :ship_to_address
  #TODO test has_contact     :accept_from => :order_and_customer_contacts
  
  should_belong_to :creator, :order, :send_quote_method, :order_form_type
  
  should_have_many :quote_items, :dependent => :delete_all
  should_have_many :end_products, :through => :quote_items
  
  should_have_attached_file :order_form
  
  should_validate_presence_of :order, :creator, :quote_contact, :with_foreign_key => :default
  
  should_validate_numericality_of :prizegiving, :carriage_costs, :discount, :deposit, :validity_delay
  
  Quote::VALIDITY_DELAY_UNITS.values.each do |unit|
    should_allow_values_for   :validity_delay_unit, unit
  end
  should_not_allow_values_for :validity_delay_unit, "anything", 1, 0, true, false, nil
  
  should_allow_values_for     :status, Quote::STATUS_CONFIRMED, Quote::STATUS_CANCELLED, Quote::STATUS_SENDED, Quote::STATUS_SIGNED, nil
  should_not_allow_values_for :status, "anything", 1, 0, true, false
  
  context "A valid and saved quote" do
    setup do
      @order = create_default_order
      @quote = create_quote_for(@order)
    end
    
    teardown do
      @order = @quote = nil
    end
    
    should "have a correct 'net' value" do
      assert_equal @quote.net, @quote.total*(1-(@quote.prizegiving/100))
    end
    
    should "have a correct 'net_to_paid' value" do
      assert_equal @quote.net_to_paid, @quote.net + @quote.carriage_costs + @quote.summon_of_taxes - @quote.discount
    end
    
    should "have a correct 'tax_coefficients' value" do
      assert_equal @quote.tax_coefficients, @quote.quote_items.collect{ |i| i.vat }.uniq
    end
    
    should "have a correct 'total_taxes_for' value" do
      @quote.tax_coefficients.each do |coefficient|
        assert_equal @quote.total_taxes_for(coefficient), @quote.quote_items.select{ |i| i.vat == coefficient}.collect(&:total).sum
      end  
    end
  end
  
  context "A valid and saved quote which we delete" do
    setup do
      @order = create_default_order
      @quote = create_quote_for(@order)
      
      @quote_item_ids = @quote.quote_items.collect(&:id)
      @end_product_ids = @order.end_products.collect(&:id)
      
      flunk "@quote should be destroyed" unless @quote.destroy
    end
    
    teardown do
      @order = @quote = @quote_item_ids = @end_product_ids = nil
    end
    
    should "delete associated quote_items" do
      @quote_item_ids.each do |quote_item_id|
        assert_nil QuoteItem.find_by_id(quote_item_id)
      end
    end
    
    should "NOT delete associated end_products" do
      @end_product_ids.each do |end_product_id|
        assert_not_nil EndProduct.find_by_id(end_product_id)
      end
    end
  end
  
  use_cases = [
    { :existing_end_products => 0, :existing_quote_items => 0, :submitted_quote_items => 1 }, # test creation of a quote_item and a end_product simultaneously
    { :existing_end_products => 1, :existing_quote_items => 0, :submitted_quote_items => 1 }, # test creation of a quote_item over an existing end_product
    { :existing_end_products => 2, :existing_quote_items => 0, :submitted_quote_items => 1 }, # test deletion of an existing end_product if a linked quote_item is not submitted
    { :existing_end_products => 1, :existing_quote_items => 1, :submitted_quote_items => 1 }, # test normal update
    { :existing_end_products => 2, :existing_quote_items => 2, :submitted_quote_items => 2,
                                                               :quote_items_to_remove => 1 }, # test deletion of quote_item and an existing end_product simultaneously
    { :existing_end_products => 3, :existing_quote_items => 3, :submitted_quote_items => 3,
                                                               :quote_items_to_remove => 3 }  # test deletion of all quote_items
  ]
  
  use_cases.each do |use_case|
    x = use_case[:existing_end_products]
    y = use_case[:existing_quote_items]
    z = use_case[:submitted_quote_items]
    quote_items_to_remove = use_case[:quote_items_to_remove] || 0
    
    quote_items_to_build  = z - y # difference between submitted_quote_items and existing_quote_items
    end_products_to_build = z - x # difference between submitted_quote_items and existing_end_products
    
    end_products_to_save = quote_items_to_save = z - quote_items_to_remove # difference between submitted_quote_items and quote_items_to_remove
    
    context "An order with #{x} end_products, and a quote with #{y} quote_items" do
      setup do
        @order = create_default_order
        x.times do
          create_default_end_product(@order)
        end
        flunk "@order should have #{x} end_products" unless @order.end_products.count == x
        
        @quote = @order.quotes.build(:validity_delay => 30, :validity_delay_unit => 'days')
        @quote.creator = users(:sales_user)
        @quote.quote_contact_id = contacts(:pierre_paul_jacques).id
        
        if y > 0
          @order.end_products.each_with_index do |end_product, index|
            break if index == y
            @quote.quote_items.build( :end_product_id  => end_product.id,
                                      :name            => "Product name",
                                      :description     => "Product description",
                                      :dimensions      => "1000x2000",
                                      :quantity        => 10,
                                      :unit_price      => 1000,
                                      :prizegiving     => 2.0,
                                      :vat             => 19.6 )
          end
          @quote.save!
          flunk "@quote should have #{y} quote_items, but has <#{@quote.quote_items.count}>" unless @quote.quote_items.count == y
        else
          flunk "@quote should be a new record without any quote_items" unless @quote.new_record? and @quote.quote_items.empty?
        end
      end
      
      teardown do
        @order = @quote = nil
      end
      
      context "in which we call 'quote_item_attributes=' with the correct parameters for #{z} quote_items" do
        setup do
          @params = []
          z.times do |time|
            quote_item = @quote.quote_items[time]
            id = quote_item ? quote_item.id : nil
            
            end_product = @order.end_products[time]
            end_product_id = end_product ? end_product.id : nil
            product_reference_id = end_product ? end_product.product_reference_id : ProductReference.first.id
            
            should_destroy = ( time < quote_items_to_remove ? 1 : nil )
            
            @params << { :id                    => id,
                         :product_reference_id  => product_reference_id,
                         :order_id              => @order.id,
                         :end_product_id        => end_product_id,
                         :name                  => "Product name",
                         :description           => "Product description",
                         :dimensions            => "1000x2000",
                         :quantity              => 10,
                         :unit_price            => 1000,
                         :prizegiving           => 2.0,
                         :vat                   => 19.6,
                         :should_destroy        => should_destroy }
          end
          flunk "@params should have #{z} elements, but has <#{@params.size}>" unless @params.size == z
          flunk "quote_item_attributes= should success" unless @quote.quote_item_attributes=(@params)
          
          @quote.valid?
        end
        
        teardown do
          @params = {}
        end
        
        if quote_items_to_build < 0
          quote_items_to_build = quote_items_to_build.abs
          
          should "set up #{quote_items_to_build} quote_items to be destroyed" do
            assert quote_items_to_build, @quote.quote_items.select(&:should_destroy?).size
          end
          
        else
          
          should "build #{quote_items_to_build} quote_items with the correct attributes" do
            new_quote_items = @quote.quote_items.select(&:new_record?)
            assert_equal quote_items_to_build, new_quote_items.size
            
            new_quote_items.each do |quote_item|
              #TODO test if attributes are correct
            end
          end
          
        end
        
        if end_products_to_build < 0
          end_products_to_build = end_products_to_build.abs
          
          should "set up #{end_products_to_build} end_products to be destroyed" do
            assert_equal end_products_to_build, @quote.order_end_products_to_remove.size
          end
        
        else
          
          should "build #{end_products_to_build} end_products with the correct attributes" do
            new_end_products = @quote.quote_items.select(&:new_record?).collect(&:end_product).select(&:new_record?)
            assert_equal end_products_to_build, new_end_products.size
            
            new_end_products.each do |end_product|
              #TODO test if attributes are correct
            end
          end
          
        end
        
        should "update #{end_products_to_save} end_products with the correct attributes" do
          #TODO check if end_product attributes have been updated
        end
        
        should "update #{quote_items_to_save} quote_items with the correct attributes" do
          #TODO check if end_product attributes have been updated
        end
        
        if quote_items_to_save > 0
        
          should "have #{quote_items_to_save} quote_items with the correct attributes after saving itself" do
            @quote.save!
            assert_equal quote_items_to_save, @quote.quote_items.count
            
            @quote.quote_items.each do |quote_item|
              assert !quote_item.new_record?
              
              #TODO test if attributes are correct
            end
          end
          
        else
          
          should "have #{quote_items_to_save} quote_items, and should be invalid because of emptiness of quote_items" do
            @quote.valid?
            assert @quote.errors.invalid?(:quote_item_ids)
          end
          
        end
        
        if end_products_to_save > 0
        
          should "have #{end_products_to_save} end_products with the correct attributes after saving itself" do
            @quote.save!
            assert_equal end_products_to_save, @quote.end_products.count
            
            @quote.end_products.each do |end_product|
              #TODO test if attributes are correct
            end
          end
          
          should "have an order which have #{end_products_to_save} end_products with the correct attributes after saving itself" do
            @quote.save!
            assert_equal end_products_to_save, @order.end_products.count
            
            @order.end_products.each do |end_product|
              #TODO test if attributes are correct
            end
          end
          
        else
          
          should "have #{end_products_to_save} end_products, and should be invalid because of emptiness of quote_items" do
            @quote.valid?
            assert @quote.errors.invalid?(:quote_item_ids)
          end
          
        end
      end
    end
  end
  
  context "Thanks to 'has_reference', a quote" do
    setup do
      @reference_owner       = create_default_quote
      @other_reference_owner = create_default_quote
    end
    
    include HasReferenceTest
  end
  
  context "Thanks to 'has_contact', a quote" do
    setup do
      @contact_owner = create_default_quote
      @contact_keys = [ :quote_contact ]
    end
    
    subject { @contact_owner }
          
    should_belong_to :quote_contact
    
    include HasContactTest
  end
end
