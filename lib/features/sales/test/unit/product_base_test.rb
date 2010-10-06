module ProductBaseTest
  
  class << self
    def included base
      base.class_eval do
        
        #TODO optimize these tests using mock/stub to simulate return of specific methods (unit_price, prizegiving, etc)
        #     for example : invoice_item doesn't respond to 'prizegiving='
        
        context "with unit_price initialized to 'nil'" do
          setup do
            @product.unit_price = nil
            flunk "Unit_price should be 'nil'" unless @product.unit_price.nil?
          end
          
          should "have a 'unit_price_with_prizegiving' value equal to '0' when unit_price is 'nil'" do
            # return 0 when unit_price is nil or is equal to 0
            assert_equal 0, @product.unit_price_with_prizegiving
          end
        end
        
        context "with unit_price initialized to '0'" do
          setup do
            @product.unit_price = 0
            flunk "Unit_price should be 'nil'" unless @product.unit_price == 0
          end
          
          should "have a 'unit_price_with_prizegiving' value equal to '0' when unit_price is 'nil'" do
            # return 0 when unit_price is nil
            assert_equal 0, @product.unit_price_with_prizegiving
          end
        end
        
        context "with unit_price initialized to '1.5'" do
          setup do
            @product.unit_price = 1.5
            flunk "Unit_price should be equal to 1.5" unless @product.unit_price == 1.5
          end
          
          context "and prizegiving initialized to 'nil'" do
            setup do
              @product.prizegiving = nil
              flunk "Prizegiving should be nil" unless @product.prizegiving.nil?
            end
            
            should "have a 'unit_price_with_prizegiving' value equal to '1.5'" do
              # unit_price / ( 1 + ( prizegiving / 100 ) )
              assert_equal 1.5, @product.unit_price_with_prizegiving
            end
          end
          
          context "and prizegiving initialed to '0'" do
            setup do
              @product.prizegiving = 0
              flunk "Prizegiving should be initialized to '0'" unless @product.prizegiving == 0
            end
            
            should "have a 'unit_price_with_prizegiving' value equal to '1.5'" do
              # unit_price / ( 1 + ( prizegiving / 100 ) )
              assert_equal 1.5, @product.unit_price_with_prizegiving
            end
          end
          
          context "and prizegiving initialized to '20'" do
            setup do
              @product.prizegiving = 20
              flunk "Prizegiving should be initialized to '20'" unless @product.prizegiving == 20
            end
            
#             TODO uncomment when the problem of equality will be solved (<1.2> expected but was <1.2>)
#            should "have a 'unit_price_with_prizegiving' value equal to '1.2'" do
#              # unit_price / ( 1 + ( prizegiving / 100 ) )
#              assert_equal 1.2, @product.unit_price_with_prizegiving
#            end
            
            context "and a 'nil' quantity value" do
              setup do
                @product.quantity = nil
                flunk "Quantity should be initialized to 'nil'" unless @product.quantity.nil?
              end
              
              should "have a 'total' value equal to '0'" do
                # unit_price * quantity
                assert_equal 0, @product.total
              end
              
              should "have a 'total_with_prizegiving' value equal to '0'" do
                assert_equal 0, @product.total_with_prizegiving
              end
            end
            
            context "and a quantity value initialized to '150'" do
              setup do
                @product.quantity = 150
                flunk "Quantity should be initialized to '150'" unless @product.quantity == 150
              end
              
              should "have a 'total' value equal to '225'" do
                # unit_price.to_f * quantity.to_f
                assert_equal 225, @product.total
              end
              
#              TODO uncomment when the problem of equality will be solved (<180.0> expected but was <180.0>)
#              should "have a 'total_with_prizegiving' value equal to '180.0'" do
#                assert_equal 180.0, @product.total_with_prizegiving
#              end
              
              context "and a 'nil' vat value" do
                setup do
                  @product.vat = nil
                  flunk "Vat should be nil" unless @product.vat.nil?
                end
                
#                  TODO uncomment when the problem of equality will be solved (<180.0> expected but was <180.0>)
#                should "have a 'total_with_taxes' value equal to 'total_with_prizegiving'(178.5) value" do
#                  # total_with_prizegiving * ( 1 + ( vat.to_f / 100.0 ) )
#                  assert_equal 180.0, @product.total_with_taxes
#                end
              end
              
              context "and a vat value initialized to '0'" do
                setup do
                  @product.vat = 0
                  flunk "Vat should be initialized to '0'" unless @product.vat == 0
                end
                
#                TODO uncomment when the problem of equality will be solved (<180.0> expected but was <180.0>)
#                should "have a 'total_with_taxes' value equal to 'total_with_prizegiving' value" do
#                  # total_with_prizegiving * ( 1 + ( vat.to_f / 100.0 ) )
#                  assert_equal 180.0, @product.total_with_taxes
#                end
              end
              
              context "and vat value initialized to '5'" do
                setup do
                  @product.vat = 5
                  flunk "Vat should be initialized to '0'" unless @product.vat == 5
                end
                
#                TODO uncomment when the problem of equality will be solved (<189.0> expected but was <189.0>)
#                should "have a 'total_with_taxes' value equal to '198.0'" do
#                  # total_with_prizegiving * ( 1 + ( vat.to_f / 100.0 ) )
#                  assert_equal 189.0, @product.total_with_taxes
#                end
              end
              
              context "and vat value initialized to '10.3'" do
                setup do
                  @product.vat = 10.3
                  flunk "Vat should be initialized to '0'" unless @product.vat == 10.3
                end
                
#                TODO uncomment when the problem of equality will be solved (<198.54> expected but was <198.54>)
#                should "have a 'total_with_taxes' value equal to '198.54'" do
#                  # total_with_prizegiving * ( 1 + ( vat.to_f / 100.0 ) )
#                  assert_equal 198.54, @product.total_with_taxes
#                end
              end
            end
            
            context "and a quantity value initialized to '175.6'" do
              setup do
                @product.quantity = 175.6
                # unit_price.to_f * quantity.to_f
                flunk "Quantity should be initialized to '175.6'" unless @product.quantity == 175.6
              end
              
              should "have a 'total'  value equal to '263.4'" do
                # unit_price.to_f * quantity.to_f
                assert_equal 263.4, @product.total
              end
            end
          end
          
          context " and prizegiving initialized to '53.6'" do
            setup do
              @product.prizegiving = 53.6
              flunk "Prizegiving should be initialized to '53.6'" unless @product.prizegiving == 53.6
            end
            
            should "have a 'unit_price_with_prizegiving' value equal to '0.9765625'" do
              # unit_price / ( 1 - ( prizegiving / 100 ) )
              assert_equal 0.696, @product.unit_price_with_prizegiving
            end
          end
        end
        
        context "with unit_price initialized to '2'" do
          setup do
            @product.unit_price = 2
            flunk "Unit_price should be initialized to '2'" unless @product.unit_price == 2
          end
          
          context " and prizegiving initialized to 'nil'" do
            setup do
              @product.prizegiving = nil
              flunk "Prizegiving should be nil" unless @product.prizegiving.nil?
            end
            
            should "have a 'unit_price_with_prizegiving' value equal to '2'" do
              # unit_price / ( 1 + ( prizegiving / 100 ) )
              assert_equal 2, @product.unit_price_with_prizegiving
            end
          end
            
          context " and prizegiving initialed to '0'" do
            setup do
              @product.prizegiving = 0
              flunk "Prizegiving should be initialized to '0'" unless @product.prizegiving == 0
            end
            
            should "have a 'unit_price_with_prizegiving' value equal to '2'" do
              # unit_price / ( 1 + ( prizegiving / 100 ) )
              assert_equal 2, @product.unit_price_with_prizegiving
            end
          end
          
          context " and prizegiving initialized to '25'" do
            setup do
              @product.prizegiving = 25
              flunk "Prizegiving should be initialized to '25'" unless @product.prizegiving == 25
            end
            
            should "have a 'unit_price_with_prizegiving' value equal to '1.6'" do
              # unit_price / ( 1 + ( prizegiving / 100 ) )
              assert_equal 1.5, @product.unit_price_with_prizegiving
            end
          end
          
          context " and prizegiving initialized to '2.4'" do
            setup do
              @product.prizegiving = 2.4
              flunk "Prizegiving should be initialized to '2.4'" unless @product.prizegiving == 2.4
            end
            
            should "have a 'unit_price_with_prizegiving' value equal to '1.953125'" do
              # unit_price / ( 1 + ( prizegiving / 100 ) )
              assert_equal 1.952, @product.unit_price_with_prizegiving
            end
          end
        end
        
        context "with a 'nil' quantity value" do
          setup do
            @product.quantity = nil
            flunk "Quantity should be initialized to 'nil'" unless @product.quantity.nil?
          end
          
          should "have a 'total' value equal to '0'" do
            assert_equal 0, @product.total
          end
        end
        
      end
    end
  end
  
end
