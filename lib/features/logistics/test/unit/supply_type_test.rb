module SupplyTypeTest
  
  class << self
    def included base
      base.class_eval do
        
        should_validate_presence_of :supply_sub_category, :with_foreign_key => :supply_category_id
        
        should "NOT generate a reference before validation without supply_category_id" do
          @supply_type.valid?
          assert_nil @supply_type.reference
        end
        
        should "generate a reference before validation if has a supply_category_id" do
          @supply_type.supply_category_id = @supply_sub_category_type.first.id
          @supply_type.valid?
          assert_not_nil @supply_type.reference
        end
        
        
        context "without children (supplies)" do
          setup do
            @supply_type.attributes = { :supply_category_id => @supply_sub_category_type.first.id,
                                        :name               => "Supply Type" }
            @supply_type.save!
            
            flunk "@supply_type should have 0 children" if @supply_type.children.to_a.any?
          end
          
          should "be editable" do
            assert @supply_type.can_be_edited?
          end
          
          should "be destroyable" do
            assert @supply_type.can_be_destroyed?
          end
          
          should "be able to be disabled" do
            assert @supply_type.can_be_disabled?
          end
          
          should "NOT be able to be enabled" do
            assert !@supply_type.can_be_enabled?
          end
          
          should "be able to have children" do
            assert @supply_type.can_have_children?
          end
          
          should "NOT have children" do
            assert !@supply_type.has_children?
          end
          
          should "NOT have enabled children" do
            assert !@supply_type.has_enabled_children?
          end
          
          should "have no stock_value at this time" do
            assert_equal 0.0, @supply_type.stock_value
          end
        end
        
        context "with active children (supplies)" do
          setup do
            @supply_type.attributes = { :supply_category_id => @supply_sub_category_type.first.id,
                                        :name               => "Supply Type" }
            @supply_type.save!
            
            @supply = @supply_type.supplies.build
            @supply.save!
          end
          
          should "be editable" do
            assert @supply_type.can_be_edited?
          end
          
          should "NOT be destroyable" do
            assert !@supply_type.can_be_destroyed?
          end
          
          should "NOT be able to be disabled" do
            assert !@supply_type.can_be_disabled?
          end
          
          should "NOT be able to be enabled" do
            assert !@supply_type.can_be_enabled?
          end
          
          should "be able to have children" do
            assert @supply_type.can_have_children?
          end
          
          should "have children" do
            assert @supply_type.has_children?
          end
          
          should "have enabled children" do
            assert @supply_type.has_enabled_children?
          end
          
          should "have no stock_value at this time" do
            assert_equal 0.0, @supply_type.stock_value
          end
          
          
          context "with stock" do
            setup do
              create_stock_input_for_supply(@supply, :sleep_delay => true, :unit_price => 5.3, :quantity => 140)
            end
            
            should "have a good stock_value" do
              assert_equal 742.0.to_d, @supply_type.stock_value # unit_price * quantity => 5.3 * 140 = 742
            end
          end
        end
        
        
        context "without active children (supplies)" do
          setup do
            @supply_type.attributes = { :supply_category_id => @supply_sub_category_type.first.id,
                                        :name               => "Supply Type" }
            @supply_type.save!
            
            ## create a supply and disable it in order to be able to disable child_category
            #@supply = create_supply_with_stock_input_for(@supply_sub_category)
            #disable_supply(@supply)
            
            # create a supply and disable it in order to be able to disable supply_type
            @supply = create_supply_for(@supply_type)
            disable_supply(@supply)
          end
          
          should "be editable" do
            assert @supply_type.can_be_edited?
          end
          
          should "NOT be destroyable" do
            assert !@supply_type.can_be_destroyed?
          end
          
          should "be able to be disabled" do
            assert @supply_type.can_be_disabled?
          end
          
          should "be disabled successfully" do
            @supply_type.disable
            assert_equal false, @supply_type.enabled_was
            assert_not_nil @supply_type.disabled_at_was
          end
          
          should "NOT be able to be enabled" do
            assert !@supply_type.can_be_enabled?
          end
          
          should "be able to have a child" do
            assert @supply_type.can_have_children?
          end
          
          should "have children" do
            assert @supply_type.has_children?
          end
          
          should "NOT have enabled children" do
            assert !@supply_type.has_enabled_children?
          end
          
          should "have no stock_value at this time" do
            assert_equal 0.0, @supply_type.stock_value
          end
          
          
          context ", which is disabled" do
            setup do
              @supply_type.disable
              flunk "@supply_type should be disabled" if @supply_type.enabled_was
            end
            
            should "NOT be editable" do
              assert !@supply_type.can_be_edited?
            end
            
            should "NOT be destroyable" do
              assert !@supply_type.can_be_destroyed?
            end
            
            should "NOT be able to be disabled 'again'" do
              assert !@supply_type.can_be_disabled?
            end
            
            should "be able to be enabled" do
              assert @supply_type.can_be_enabled?
            end
            
            should "be enabled successfully" do
              @supply_type.enable
              assert @supply_type.enabled_was
              assert_nil @supply_type.disabled_at_was
            end
            
            should "NOT be able to have a child" do
              assert !@supply_type.can_have_children?
            end
            
            should "have children" do
              assert @supply_type.has_children?
            end
            
            should "NOT have enabled children" do
              assert !@supply_type.has_enabled_children?
            end
            
            should "have no stock_value at this time" do
              assert_equal 0.0, @supply_type.stock_value
            end
          end
        end
        
        context "which is saved" do
          setup do
            @supply_type.attributes = { :supply_category_id => @supply_sub_category_type.first.id,
                                        :name               => "Supply Sub Category" }
            @supply_type.save!
          end
          
          should "count itself in its self_and_siblings" do
            assert @supply_type.self_and_siblings.include?(@supply_type)
          end
          
          should "NOT count itself in its siblings" do
            assert !@supply_type.siblings.include?(@supply_type)
          end
        end
        
      end
    end
  end
  
end
