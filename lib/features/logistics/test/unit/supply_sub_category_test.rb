module SupplySubCategoryTest
  
  class << self
    def included base
      base.class_eval do
        
        #TODO test stock_value when sub_category has got supply which are disabled
        
        should_belong_to :unit_measure
        
        should_have_many :supply_categories_supply_sizes
        should_have_many :supply_sizes, :through => :supply_categories_supply_sizes
        
        should_validate_presence_of :supply_category, :with_foreign_key => :default
        
        #TODO
        #validates_persistence_of :supply_category_id
        #validates_persistence_of :name, :unit_measure_id, :if => :has_children?
        
        should "NOT generate a reference before validation without supply_category_id" do
          @supply_sub_category.valid?
          assert_nil @supply_sub_category.reference
        end
        
        should "generate a reference before validation if has a supply_category_id" do
          @supply_sub_category.supply_category_id = @supply_category_type.first.id
          @supply_sub_category.valid?
          assert_not_nil @supply_sub_category.reference
        end
        
        # test supply_categories_supply_size_attributes=
        should "build supply_categories_supply_sizes when calling supply_categories_supply_size_attributes=" do
          @supply_sub_category.supply_categories_supply_size_attributes=([{ :supply_size_id   => supply_sizes(:diameter).id,
                                                                            :unit_measure_id  => unit_measures(:millimeter).id },
                                                                          { :supply_size_id   => supply_sizes(:length).id,
                                                                            :unit_measure_id  => unit_measures(:millimeter).id }])
          
          assert_equal 2, @supply_sub_category.supply_categories_supply_sizes.size
        end
        
        # test validates_uniqueness_of_supply_sizes
        should "have a validation error if have 2 supply_categories_supply_sizes belonging to the same supply_size" do
          @supply_sub_category.attributes = { :supply_categories_supply_size_attributes => [
                                              { :supply_size_id   => supply_sizes(:diameter).id,
                                                :unit_measure_id  => unit_measures(:millimeter).id },
                                              { :supply_size_id   => supply_sizes(:diameter).id, # same supply_size as first
                                                :unit_measure_id  => unit_measures(:millimeter).id } ] }
          @supply_sub_category.valid?
          
          assert @supply_sub_category.errors.invalid?(:supply_categories_supply_sizes)
          assert_match /La même spécificité a été sélectionnée deux fois/, @supply_sub_category.errors.on(:supply_categories_supply_sizes)
        end
        
        
        context "without children (supply_types)" do
          setup do
            @supply_sub_category.attributes = { :supply_category_id => @supply_category_type.first.id,
                                                :name               => "Supply Sub Category" }
            @supply_sub_category.save!
            
            flunk "@supply_sub_category should have 0 children" if @supply_sub_category.children.to_a.any?
          end
          
          should "be editable" do
            assert @supply_sub_category.can_be_edited?
          end
          
          should "be destroyable" do
            assert @supply_sub_category.can_be_destroyed?
          end
          
          should "be able to be disabled" do
            assert @supply_sub_category.can_be_disabled?
          end
          
          should "NOT be able to be enabled" do
            assert !@supply_sub_category.can_be_enabled?
          end
          
          should "be able to have children" do
            assert @supply_sub_category.can_have_children?
          end
          
          should "NOT have children" do
            assert !@supply_sub_category.has_children?
          end
          
          should "NOT have enabled children" do
            assert !@supply_sub_category.has_enabled_children?
          end
          
          should "have no stock_value at this time" do
            assert_equal 0.0, @supply_sub_category.stock_value
          end
        end
        
        context "with active children (supply_types)" do
          setup do
            @supply_sub_category.attributes = { :supply_category_id => @supply_category_type.first.id,
                                                :name               => "Supply Sub Category" }
            @supply_sub_category.save!
            
            @supply_type = @supply_sub_category.supply_types.build(:name => "Child Category")
            @supply_type.save!
          end
          
          should "be editable" do
            assert @supply_sub_category.can_be_edited?
          end
          
          should "NOT be destroyable" do
            assert !@supply_sub_category.can_be_destroyed?
          end
          
          should "NOT be able to be disabled" do
            assert !@supply_sub_category.can_be_disabled?
          end
          
          should "NOT be able to be enabled" do
            assert !@supply_sub_category.can_be_enabled?
          end
          
          should "be able to have children" do
            assert @supply_sub_category.can_have_children?
          end
          
          should "have children" do
            assert @supply_sub_category.has_children?
          end
          
          should "have enabled children" do
            assert @supply_sub_category.has_enabled_children?
          end
          
          should "have no stock_value at this time" do
            assert_equal 0.0, @supply_sub_category.stock_value
          end
          
          
          context "which have supplies with stock" do
            setup do
              create_supply_with_stock_input_for(@supply_sub_category)
            end
            
            should "have a good stock_value" do
              assert_equal BigDecimal.new("10000"), @supply_sub_category.stock_value # unit_price * quantity => 100 * 100 = 10000
            end
          end
        end
        
        
        context "without active children (supply_types)" do
          setup do
            @supply_sub_category.attributes = { :supply_category_id => @supply_category_type.first.id,
                                                :name               => "Supply Sub Category" }
            @supply_sub_category.save!
            
            # create a supply_type and disable it (to have at least 1 disabled child)
            @supply_type = create_supply_type_for(@supply_sub_category)
            disable_supply_type(@supply_type)
          end
          
          should "be editable" do
            assert @supply_sub_category.can_be_edited?
          end
          
          should "NOT be destroyable" do
            assert !@supply_sub_category.can_be_destroyed?
          end
          
          should "be able to be disabled" do
            assert @supply_sub_category.can_be_disabled?
          end
          
          should "be disabled successfully" do
            @supply_sub_category.disable
            assert_equal false, @supply_sub_category.enabled_was
            assert_not_nil @supply_sub_category.disabled_at_was
          end
          
          should "NOT be able to be enabled" do
            assert !@supply_sub_category.can_be_enabled?
          end
          
          should "be able to have a child" do
            assert @supply_sub_category.can_have_children?
          end
          
          should "have children" do
            assert @supply_sub_category.has_children?
          end
          
          should "NOT have enabled children" do
            assert !@supply_sub_category.has_enabled_children?
          end
          
          should "have no stock_value at this time" do
            assert_equal 0.0, @supply_sub_category.stock_value
          end
          
          
          context ", which is disabled" do
            setup do
              @supply_sub_category.disable
              flunk "@supply_sub_category should be disabled" if @supply_sub_category.enabled_was
            end
            
            should "NOT be editable" do
              assert !@supply_sub_category.can_be_edited?
            end
            
            should "NOT be destroyable" do
              assert !@supply_sub_category.can_be_destroyed?
            end
            
            should "NOT be able to be disabled 'again'" do
              assert !@supply_sub_category.can_be_disabled?
            end
            
            should "be able to be enabled" do
              assert @supply_sub_category.can_be_enabled?
            end
            
            should "be enabled successfully" do
              @supply_sub_category.enable
              assert @supply_sub_category.enabled_was
              assert_nil @supply_sub_category.disabled_at_was
            end
            
            should "NOT be able to have a child" do
              assert !@supply_sub_category.can_have_children?
            end
            
            should "have children" do
              assert @supply_sub_category.has_children?
            end
            
            should "NOT have enabled children" do
              assert !@supply_sub_category.has_enabled_children?
            end
            
            should "have no stock_value at this time" do
              assert_equal 0.0, @supply_sub_category.stock_value
            end
          end
        end
        
        context "which is saved" do
          setup do
            @supply_sub_category.attributes = { :supply_category_id => @supply_category_type.first.id,
                                                :name               => "Supply Sub Category" }
            @supply_sub_category.save!
          end
          
          should "count itself in its self_and_siblings" do
            assert @supply_sub_category.self_and_siblings.include?(@supply_sub_category)
          end
          
          should "NOT count itself in its siblings" do
            assert !@supply_sub_category.siblings.include?(@supply_sub_category)
          end
        end
        
      end
    end
  end
  
end
