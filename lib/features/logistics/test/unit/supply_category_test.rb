module SupplyCategoryTest
  
  module OnlyFirstLevelCategoriesMethods
    class << self
      def included base
        base.class_eval do
          
          should "generate a reference before validation" do
            @supply_category.valid?
            assert_not_nil @supply_category.reference
          end
          
          context "without children (sub categories)" do
            setup do
              @supply_category.attributes = { :name => "Supply Category" }
              @supply_category.save!
              
              flunk "@supply_category should have 0 children" if @supply_category.children.to_a.any?
            end
            
            should "be editable" do
              assert @supply_category.can_be_edited?
            end
            
            should "be destroyable" do
              assert @supply_category.can_be_destroyed?
            end
            
            should "be able to be disabled" do
              assert @supply_category.can_be_disabled?
            end
            
            should "be disabled successfully" do
              @supply_category.disable
              assert_equal false, @supply_category.enabled_was
              assert_not_nil @supply_category.disabled_at_was
            end
            
            should "NOT be able to be enabled" do
              assert !@supply_category.can_be_enabled?
            end
            
            should "be able to have children" do
              assert @supply_category.can_have_children?
            end
            
            should "NOT have children" do
              assert !@supply_category.has_children?
            end
            
            should "NOT have enabled children" do
              assert !@supply_category.has_enabled_children?
            end
            
            should "have no stock_value at this time" do
              assert_equal 0.0, @supply_category.stock_value
            end
          end
          
          
          context "with active children (sub categories)" do
            setup do
              @supply_category.attributes = { :name => "Supply Category" }
              @supply_category.save!
              
              @supply_sub_category = @supply_category.children.build(:name => "Supply Sub Category")
              @supply_sub_category.save!
              
              flunk "@supply_category should have at least 1 child" unless @supply_category.children.enabled.to_a.any?
            end
            
            should "be editable" do
              assert @supply_category.can_be_edited?
            end
            
            should "NOT be destroyable" do
              assert !@supply_category.can_be_destroyed?
            end
            
            should "NOT be able to be disabled" do
              assert !@supply_category.can_be_disabled?
            end
            
            should "NOT be able to be enabled" do
              assert !@supply_category.can_be_enabled?
            end
            
            should "be able to have children" do
              assert @supply_category.can_have_children?
            end
            
            should "have children" do
              assert @supply_category.has_children?
            end
            
            should "have enabled children" do
              assert @supply_category.has_enabled_children?
            end
            
            should "have no stock_value at this time" do
              assert_equal 0.0, @supply_category.stock_value
            end
            
            
            context "which have supplies with stock" do
              setup do
                create_supply_with_stock_input_for(@supply_sub_category)
              end
              
              should "have a good stock_value" do
                assert_equal BigDecimal.new("10000"), @supply_category.stock_value # unit_price * quantity => 100 * 100 = 10000
              end
            end
          end
          
          
          context "without active children (sub categories)" do
            setup do
              @supply_category.attributes = { :name => "Supply Category" }
              @supply_category.save!
              
              # create a supply_sub_category and disable it (to have at least 1 disabled child)
              @supply_sub_category = @supply_category.children.build(:name => "Supply Sub Category")
              @supply_sub_category.save!
              @supply_sub_category.disable
              flunk "@supply_sub_category should be disabled" if @supply_sub_category.enabled_was
            end
            
            should "be editable" do
              assert @supply_category.can_be_edited?
            end
            
            should "NOT be destroyable" do
              assert !@supply_category.can_be_destroyed?
            end
            
            should "be able to be disabled" do
              assert @supply_category.can_be_disabled?
            end
            
            should "be disabled successfully" do
              @supply_category.disable
              assert_equal false, @supply_category.enabled_was
              assert_not_nil @supply_category.disabled_at_was
            end
            
            should "NOT be able to be enabled" do
              assert !@supply_category.can_be_enabled?
            end
            
            should "be able to have a child" do
              assert @supply_category.can_have_children?
            end
            
            should "have children" do
              assert @supply_category.has_children?
            end
            
            should "NOT have enabled children" do
              assert !@supply_category.has_enabled_children?
            end
            
            should "have no stock_value at this time" do
              assert_equal 0.0, @supply_category.stock_value
            end
            
            
            context ", which is disabled" do
              setup do
                @supply_category.disable
                flunk "@supply_category should be disabled" if @supply_category.enabled_was
              end
              
              should "NOT be editable" do
                assert !@supply_category.can_be_edited?
              end
              
              should "NOT be destroyable" do
                assert !@supply_category.can_be_destroyed?
              end
              
              should "NOT be able to be disabled 'again'" do
                assert !@supply_category.can_be_disabled?
              end
              
              should "be able to be enabled" do
                assert @supply_category.can_be_enabled?
              end
              
              should "be enabled successfully" do
                @supply_category.enable
                assert @supply_category.enabled_was
                assert_nil @supply_category.disabled_at_was
              end
              
              should "NOT be able to have a child" do
                assert !@supply_category.can_have_children?
              end
              
              should "have children" do
                assert @supply_category.has_children?
              end
              
              should "NOT have enabled children" do
                assert !@supply_category.has_enabled_children?
              end
              
              should "have no stock_value at this time" do
                assert_equal 0.0, @supply_category.stock_value
              end
            end
          end
          
          context "which is saved" do
            setup do
              @supply_category.attributes = { :name => "Supply Category" }
              @supply_category.save!
            end
            
            should "count itself in its self_and_siblings" do
              assert @supply_category.self_and_siblings.include?(@supply_category)
            end
            
            should "NOT count itself in its siblings" do
              assert !@supply_category.siblings.include?(@supply_category)
            end
          end
          
        end
      end
    end
  end
  
  module CommonMethods
    class << self
      def included base
        base.class_eval do
          
          #TODO test stock_value when category has got sub_category or supplies which are disabled
          
          should_validate_presence_of :name
          
          #TODO
          #validates_persistence_of :reference
          
          should_validate_uniqueness_of :name, :scoped_to => [ :type, :supply_category_id ]
          #should_validate_uniqueness_of :reference, :scoped_to => :type # this fail because should_validate_uniqueness_of check uniqueness with a nil value but reference is automatically generated before validation
          
          should "have no reference" do
            assert_nil @supply_category.reference
          end
          
          should "be editable" do
            assert @supply_category.can_be_edited?
          end
          
          should "be destroyable" do
            assert @supply_category.can_be_destroyed?
          end
          
          should "be able to be disabled" do
            assert @supply_category.can_be_disabled?
          end
          
          should "NOT be able to be enabled" do
            assert !@supply_category.can_be_enabled?
          end
          
          should "be able to have children" do
            assert @supply_category.can_have_children?
          end
          
          should "NOT have children" do
            assert !@supply_category.has_children?
          end
          
          should "NOT have enabled children" do
            assert !@supply_category.has_enabled_children?
          end
          
          should "have self_and_siblings" do
            assert @supply_category.self_and_siblings.any?
          end
          
          should "have siblings" do
            assert @supply_category.siblings.any?
          end
          
        end
      end
    end
  end
  
end
