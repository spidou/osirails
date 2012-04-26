module ProductBaseTest
  
  class << self
    def included base
      base.class_eval do
        
        #TODO optimize these tests using mock/stub to simulate return of specific methods (unit_price, prizegiving, etc)
        #     for example : invoice_item doesn't respond to 'prizegiving='
        
        should "have a 'unit_price_with_prizegiving' value equal to '0' when unit_price is nil" do
          @product.unit_price = nil
          assert_equal 0, @product.unit_price_with_prizegiving
        end
        
        [nil, 0].each do |prizegiving|
          should "have a correct 'unit_price_with_prizegiving' value when prizegiving is equal to '#{prizegiving}'" do
            @product.prizegiving = prizegiving
            expected_value = @product.unit_price
            
            assert_equal expected_value, @product.unit_price_with_prizegiving
          end
        end
        
        [1, 8.0, 15.5, 30.79].each do |prizegiving|
          should "have a correct 'unit_price_with_prizegiving' value when prizegiving is equal to '#{prizegiving}'" do
            prizegiving = BigDecimal.new(prizegiving.to_s)
            @product.prizegiving = prizegiving
            expected_value = BigDecimal.new(@product.unit_price.to_s) * ( 1 - ( prizegiving / 100 ) )
            
            assert_equal expected_value, @product.unit_price_with_prizegiving
          end
        end
        
        should "have a 'total' value equal to '0' when quantity is nil" do
          @product.quantity = nil
          assert_equal 0, @product.total
        end
        
        [1, 8.0, 15.5, 30.79].each do |quantity|
          should "have a correct 'total' value when quantity is equal to '#{quantity}'" do
            @product.quantity = quantity
            expected_value = @product.unit_price_with_prizegiving * quantity
            assert_equal expected_value, @product.total
          end
        end
        
        [0, 0.0].each do |vat|
          should "have a 'total_with_taxes' value equal to 'total' when vat is equal to #{vat.inspect}" do
            @product.vat = vat
            assert_equal @product.total, @product.total_with_taxes
          end
        end
        
        [1, 8.0, 15.5, 30.79].each do |vat|
          should "have a correct 'total_with_taxes' value when vat is equal to '#{vat}'" do
            @product.vat = vat
            expected_value = @product.total + (@product.total * ( vat.to_f / 100 ))
            assert_equal expected_value, @product.total_with_taxes
          end
        end
        
      end
    end
  end
  
end
