module SupplyTest
  class << self
    def included base
      base.class_eval do
        
        #TODO test the following methods
        # was_enabled_at
        # supplier_supply_attributes=
        # supplies_supply_size_attributes=
        # update_supply_sub_category_counter
        # self.was_enabled_at
        # self.restockables
        # self.stock_value
        
        should_have_many :supplier_supplies
        should_have_many :suppliers, :through => :supplier_supplies
        
        should_have_many :stock_flows
        should_have_many :stock_inputs
        should_have_many :stock_outputs
        
        should_have_many :supplies_supply_sizes
        should_have_many :supply_sizes, :through => :supplies_supply_sizes

        should_validate_presence_of :name, :reference
        should_validate_presence_of :supply_sub_category, :with_foreign_key => :default
        
        should_validate_numericality_of :unit_mass, :measure, :threshold, :packaging
        
        #TODO
        #validates_persistence_of :supply_sub_category_id, :name, :reference, :measure, :unit_mass, :packaging, :supplies_supply_sizes, :if => :persistence_case?
        
        should "be enabled" do
          assert @supply.enabled?
        end
        
        should "have an empty humanized_supply_sizes" do
          assert_equal "", @supply.humanized_supply_sizes
        end
        
        should "NOT have a designation" do
          assert_nil @supply.designation
        end
        
        should "NOT have a supply_category" do
          assert_nil @supply.supply_category
        end
        
        should "NOT have a supply_category_id" do
          assert_nil @supply.supply_category_id
        end
        
        should "have NO ancestors" do
          assert_equal [], @supply.ancestors
        end
        
        should "have NO self_and_siblings" do
          assert_equal [], @supply.self_and_siblings
        end
        
        should "have NO siblings" do
          assert_equal [], @supply.siblings
        end
        
        should "NOT generate a reference before validation without supply_sub_category_id" do
          @supply.valid?
          assert_nil @supply.reference
        end
        
        should "generate a reference before validation if has a supply_sub_category_id" do
          @supply.supply_sub_category_id = @supply_sub_category_type.first.id
          @supply.valid?
          assert_not_nil @supply.reference
        end
        
        should "NOT have been used" do
          assert !@supply.has_been_used?
        end
        
        should "NOT be editable" do
          assert !@supply.can_be_edited?
        end
        
        should "be destroyable" do
          assert @supply.can_be_destroyed?
        end
        
        should "be destroyed successfully" do
          assert @supply.destroy
        end
        
        should "NOT be able to be disabled" do
          assert !@supply.can_be_disabled?
        end
        
        should "NOT be disabled" do
          assert !@supply.disable
        end
        
        should "NOT be able to be enabled" do
          assert !@supply.can_be_enabled?
        end
        
        should "NOT be enabled" do
          assert !@supply.enable
        end
        
        context "with a supply_sub_category" do
          setup do
            @supply_sub_category = @supply_sub_category_type.first
            @supply_category = @supply_sub_category.supply_category
            
            @supply.supply_sub_category = @supply_sub_category
          end
          
          should "have a supply_category" do
            assert_equal @supply_category, @supply.supply_category
          end
          
          should "have a supply_category_id" do
            assert_equal @supply_category.id, @supply.supply_category_id
          end
          
          should "have ancestors" do
            assert_equal [@supply_sub_category, @supply_category], @supply.ancestors
          end
          
          should "have self_and_siblings" do
            assert @supply.self_and_siblings.any?
          end
          
          should "have siblings" do
            assert @supply.siblings.any?
          end
        end
        
        context "which is saved" do
          setup do
            parent = @supply_sub_category_type.first
            parent.attributes = { :supply_categories_supply_size_attributes => [
                                    { :supply_size_id   => supply_sizes(:diameter).id,
                                      :unit_measure_id  => unit_measures(:millimeter).id },
                                    { :supply_size_id   => supply_sizes(:width).id,
                                      :unit_measure_id  => unit_measures(:millimeter).id },
                                    { :supply_size_id   => supply_sizes(:length).id,
                                      :unit_measure_id  => unit_measures(:meter).id } ] }
            parent.save!
            
            @supply.attributes = { :supply_sub_category_id => parent.id, :name => "Supply" }
            @supply.save!
          end
          
          should "have an empty humanized_supply_sizes" do
            assert_equal "", @supply.humanized_supply_sizes
          end
          
          should "have a valid designation" do
            expected_value = "#{@supply.supply_category.name} #{@supply.supply_sub_category.name} Supply" # supply_category.name      => "First Commodity Category"
                                                                                                          # supply_sub_category.name  => "First Commodity Sub Category"
                                                                                                          # name                      => "Supply"
            assert_equal expected_value, @supply.designation
          end
          
          should "have self_and_siblings" do
            assert @supply.self_and_siblings.any?
          end
          
          should "count itself in its self_and_siblings" do
            assert @supply.self_and_siblings.include?(@supply)
          end
          
          should "NOT count itself in its siblings" do
            assert !@supply.siblings.include?(@supply)
          end
          
          context "with 1 supply_size" do
            setup do
              @supply.attributes = { :supplies_supply_size_attributes => [ { :supply_size_id   => supply_sizes(:diameter).id,
                                                                             :unit_measure_id  => unit_measures(:millimeter).id,
                                                                             :value            => "20" } ] }
              @supply.save!
            end
            
            should "have a valid humanized_supply_sizes" do
              expected_value = "20 mm"  # supply_size1.value                => "20"
                                        # supply_size1.unit_measure.symbol  => "mm"
              assert_equal expected_value, @supply.humanized_supply_sizes
            end
            
            should "have a valid designation" do
              expected_value = "#{@supply.supply_category.name} #{@supply.supply_sub_category.name} Supply 20 mm" # supply_category.name      => "First Commodity Category"
                                                                                                                  # supply_sub_category.name  => "First Commodity Sub Category"
                                                                                                                  # name                      => "Supply"
                                                                                                                  # humanized_supply_sizes    => "20 mm"
              assert_equal expected_value, @supply.designation
            end
          end
          
          context "with 2 supply_sizes with same unit_measure" do
            setup do
              @supply.attributes = { :supplies_supply_size_attributes => [ { :supply_size_id   => supply_sizes(:diameter).id,
                                                                             :unit_measure_id  => unit_measures(:millimeter).id,
                                                                             :value            => "20" },
                                                                           { :supply_size_id   => supply_sizes(:width).id,
                                                                             :unit_measure_id  => unit_measures(:millimeter).id,
                                                                             :value            => "40" } ] }
              @supply.save!
            end
            
            should "have a valid humanized_supply_sizes" do
              expected_value = "20 x 40 mm" # supply_size1.value               => "20"
                                            # delimiter                        => " x "
                                            # supply_size2.value               => "40"
                                            # supply_size2.unit_measure.symbol => "mm"
              assert_equal expected_value, @supply.humanized_supply_sizes
            end
            
            should "have a valid designation" do
              expected_value = "#{@supply.supply_category.name} #{@supply.supply_sub_category.name} Supply 20 x 40 mm"  # supply_category.name      => "First Commodity Category"
                                                                                                                        # supply_sub_category.name  => "First Commodity Sub Category"
                                                                                                                        # name                      => "Supply"
                                                                                                                        # humanized_supply_sizes    => "20 x 40 mm"
              assert_equal expected_value, @supply.designation
            end
          end
          
          context "with 2 supply_sizes with different unit_measure" do
            setup do
              @supply.attributes = { :supplies_supply_size_attributes => [ { :supply_size_id   => supply_sizes(:diameter).id,
                                                                             :unit_measure_id  => unit_measures(:millimeter).id,
                                                                             :value            => "20" },
                                                                           { :supply_size_id   => supply_sizes(:length).id,
                                                                             :unit_measure_id  => unit_measures(:meter).id,
                                                                             :value            => "6" } ] }
              @supply.save!
            end
            
            should "have a valid humanized_supply_sizes" do
              expected_value = "20 mm, 6 m" # supply_size1.value                => "20"
                                            # supply_size1.unit_measure.symbol  => "mm"
                                            # delimiter                         => ", "
                                            # supply_size2.value                => "6"
                                            # supply_size2.unit_measure.symbol  => "m"
              assert_equal expected_value, @supply.humanized_supply_sizes
            end
            
            should "have a valid designation" do
              expected_value = "#{@supply.supply_category.name} #{@supply.supply_sub_category.name} Supply 20 mm, 6 m"  # supply_category.name      => "First Commodity Category"
                                                                                                                        # supply_sub_category.name  => "First Commodity Sub Category"
                                                                                                                        # name                      => "Supply"
                                                                                                                        # humanized_supply_sizes    => "20 mm, 6 m"
              assert_equal expected_value, @supply.designation
            end
          end
        end
        
        context "which has at least 1 stock_flow" do
          setup do
            @supply.attributes = { :supply_sub_category_id => @supply_sub_category_type.first.id, :name => "Supply" }
            @supply.save!
            
            create_stock_input_for_supply(@supply, :sleep_delay => true)
          end
          
          should "have been used" do
            assert @supply.has_been_used?
          end
          
          should "be editable" do
            assert @supply.can_be_edited?
          end
          
          should "NOT be destroyable" do
            assert !@supply.can_be_destroyed?
          end
          
          should "NOT be destroyed" do
            assert !@supply.destroy
          end
          
          should "NOT be able to be disabled" do
            assert !@supply.can_be_disabled?
          end
          
          should "NOT be disabled" do
            assert !@supply.disable
          end
          
          should "NOT be able to be enabled" do
            assert !@supply.can_be_enabled?
          end
          
          should "NOT be enabled" do
            assert !@supply.enable
          end
          
          context ", and with stock_quantity at 0" do
            setup do
              create_stock_output_to_set_stock_quantity_at_zero_for_supply(@supply)
              flunk "supply should have a stock_quantity at 0\nbut was #{@supply.stock_quantity}" unless @supply.stock_quantity.zero?
            end
            
            should "be editable" do
              assert @supply.can_be_edited?
            end
            
            should "NOT be destroyable" do
              assert !@supply.can_be_destroyed?
            end
            
            should "NOT be destroyed" do
              assert !@supply.destroy
            end
            
            should "be able to be disabled" do
              assert @supply.can_be_disabled?
            end
            
            should "be disabled successfully" do
              @supply.disable
              assert !@supply.enabled_was
              assert_not_nil @supply.disabled_at_was
            end
            
            should "NOT be able to be enabled" do
              assert !@supply.can_be_enabled?
            end
            
            should "NOT be enabled" do
              assert !@supply.enable
            end
            
            
            context ", which is disabled" do
              setup do
                disable_supply(@supply)
              end
              
              should "NOT be editable" do
                assert !@supply.can_be_edited?
              end
              
              should "NOT be destroyable" do
                assert !@supply.can_be_destroyed?
              end
              
              should "NOT be destroyed" do
                assert !@supply.destroy
              end
              
              should "NOT be able to be disabled 'again'" do
                assert !@supply.can_be_disabled?
              end
              
              should "NOT be disabled 'again'" do
                assert !@supply.disable
              end
              
              should "be able to be enabled" do
                assert @supply.can_be_enabled?
              end
              
              should "be enabled successfully" do
                @supply.enable
                assert @supply.enabled_was
                assert_nil @supply.disabled_at_was
              end
            end
          end
        end
        
        # test validates_uniqueness_of_supplies_supply_sizes_scoped_by_name
        context "with another existing supply in the same parent_category," do
          setup do
            parent = @supply_sub_category_type.first
            parent.attributes = { :supply_categories_supply_size_attributes => [
                                    { :supply_size_id   => supply_sizes(:diameter).id,
                                      :unit_measure_id  => unit_measures(:millimeter).id },
                                    { :supply_size_id   => supply_sizes(:width).id,
                                      :unit_measure_id  => unit_measures(:millimeter).id } ] }
            parent.save!
            
            @another_supply = parent.supplies.build(  :name => "Supply",
                                                      :supplies_supply_size_attributes => [
                                                       { :supply_size_id   => supply_sizes(:diameter).id,
                                                         :unit_measure_id  => unit_measures(:millimeter).id,
                                                         :value            => "20" },
                                                       { :supply_size_id   => supply_sizes(:width).id,
                                                         :unit_measure_id  => unit_measures(:millimeter).id,
                                                         :value            => "1000" } ] )
            @another_supply.save!
            flunk "parent should have @another_supply has a child" unless parent.supplies.include?(@another_supply)
            flunk "@another_supply should have 2 supplies_supply_sizes" unless @another_supply.supplies_supply_sizes.count == 2
            
            @supply = parent.supplies.build
          end
          
          should "NOT be valid if name and supply_size's values are exactly the same" do
            @supply.attributes = { :name => "Supply",
                                   :supplies_supply_size_attributes => [
                                    { :supply_size_id   => supply_sizes(:diameter).id,
                                      :unit_measure_id  => unit_measures(:millimeter).id,
                                      :value            => "20" },
                                    { :supply_size_id   => supply_sizes(:width).id,
                                      :unit_measure_id  => unit_measures(:millimeter).id,
                                      :value            => "1000" } ] }
            @supply.valid?
            
            assert @supply.errors.invalid?(:supplies_supply_sizes)
            assert_match /La famille choisie contient déjà une fourniture avec le même type et les mêmes spécificités \(#{@supply.designation}\)/, @supply.errors.on(:supplies_supply_sizes)
            assert @supply.errors.invalid?(:name)
            assert_equal 2, @supply.supplies_supply_sizes.select{ |s| s.errors.on(:value) }.size
          end
          
          should "be valid if name is the same, but not the supply_size's values" do
            @supply.attributes = { :name => "Supply",
                                   :supplies_supply_size_attributes => [
                                    { :supply_size_id   => supply_sizes(:diameter).id,
                                      :unit_measure_id  => unit_measures(:millimeter).id,
                                      :value            => "30" },
                                    { :supply_size_id   => supply_sizes(:width).id,
                                      :unit_measure_id  => unit_measures(:millimeter).id,
                                      :value            => "1000" } ] }
            @supply.valid?
            
            assert !@supply.errors.invalid?(:supplies_supply_sizes)
          end
          
          should "be valid if the supply_size's values are the same, but not the name" do
            @supply.attributes = { :name => "Second Supply",
                                   :supplies_supply_size_attributes => [
                                    { :supply_size_id   => supply_sizes(:diameter).id,
                                      :unit_measure_id  => unit_measures(:millimeter).id,
                                      :value            => "20" },
                                    { :supply_size_id   => supply_sizes(:width).id,
                                      :unit_measure_id  => unit_measures(:millimeter).id,
                                      :value            => "1000" } ] }
            @supply.valid?
            
            assert !@supply.errors.invalid?(:supplies_supply_sizes)
          end
          
          context "which is saved" do
            setup do
              @supply.name = "Supply"
              @supply.save!
            end
            
            should "have self_and_siblings" do
              assert @supply.self_and_siblings.any?
            end
            
            should "count itself in its self_and_siblings" do
              assert @supply.self_and_siblings.include?(@supply)
            end
            
            should "have siblings" do
              assert @supply.siblings.any?
            end
            
            should "NOT count itself in its siblings" do
              assert !@supply.siblings.include?(@supply)
            end
          end
          
        end
        
        # test validates_supplies_supply_sizes_according_to_sub_category
        context "belonging to a parent_category with specific supply_sizes" do
          setup do
            parent = @supply_sub_category_type.first
            parent.attributes = { :supply_categories_supply_size_attributes => [
                                    { :supply_size_id   => supply_sizes(:diameter).id,
                                      :unit_measure_id  => unit_measures(:millimeter).id },
                                    { :supply_size_id   => supply_sizes(:width).id,
                                      :unit_measure_id  => unit_measures(:millimeter).id } ] }
            parent.save!
            
            @supply.attributes = { :name => "Supply", :supply_sub_category_id => parent.id }
          end
          
          should "be valid if has no supply_sizes" do
            @supply.valid?
            assert !@supply.errors.invalid?(:supplies_supply_sizes)
          end
          
          should "be valid if has a part of supply_sizes among the parent_category's supply_sizes" do
            @supply.attributes = { :supplies_supply_size_attributes => [
                                    { :supply_size_id   => supply_sizes(:diameter).id,
                                      :unit_measure_id  => unit_measures(:millimeter).id,
                                      :value            => "20" } ] }
            @supply.valid?
            assert !@supply.errors.invalid?(:supplies_supply_sizes)
          end
          
          should "be valid if has all supply_sizes of the parent_category's supply_sizes" do
            @supply.attributes = { :supplies_supply_size_attributes => [
                                    { :supply_size_id   => supply_sizes(:diameter).id,
                                      :unit_measure_id  => unit_measures(:millimeter).id,
                                      :value            => "20" },
                                    { :supply_size_id   => supply_sizes(:width).id,
                                      :unit_measure_id  => unit_measures(:millimeter).id,
                                      :value            => "1000" } ] }
            @supply.valid?
            assert !@supply.errors.invalid?(:supplies_supply_sizes)
          end
          
          should "NOT be valid if has at least 1 supply_sizes which is not in the parent_category's supply_sizes" do
            @supply.attributes = { :supplies_supply_size_attributes => [
                                    { :supply_size_id   => supply_sizes(:length).id,
                                      :unit_measure_id  => unit_measures(:millimeter).id,
                                      :value            => "20" } ] }
            @supply.valid?
            
            assert @supply.errors.invalid?(:supplies_supply_sizes)
            assert_match /Les spécificités de la fourniture ne correspondent pas à celles de la sous-famille choisie/, @supply.errors.on(:supplies_supply_sizes)
          end
        end
        
        context "which is saved and have many stock_flows" do
          setup do
            @supply.attributes = { :supply_sub_category_id => @supply_sub_category_type.first.id, :name => "Supply" }
            @supply.save!
            
            @stock_flow1 = create_stock_input_for_supply(@supply, :unit_price => 100, :quantity => 100, :created_at => Time.zone.parse("2009-01-01"))
            @stock_flow2 = create_stock_input_for_supply(@supply, :unit_price => 100, :quantity => 100, :created_at => Time.zone.parse("2009-02-01"))
            @stock_flow3 = create_stock_input_for_supply(@supply, :unit_price => 100, :quantity => 100, :created_at => Time.zone.parse("2009-03-01"))
          end
          
          # test last_stock_flow
          should "have a last_stock_flow from now" do
            assert_equal @stock_flow3, @supply.last_stock_flow
          end
          
          should "have a last_stock_flow from 15th February 2009" do
            assert_equal @stock_flow2, @supply.last_stock_flow(Time.zone.parse("2009-02-15"))
          end
          
          should "NOT have a last_stock_flow from 31st December 2008" do
            assert_nil @supply.last_stock_flow(Time.zone.parse("2008-12-31"))
          end
        end
        
        context "which is saved and have many inventories" do
          setup do
            @supply.attributes = { :supply_sub_category_id => @supply_sub_category_type.first.id, :name => "Supply" }
            @supply.save!
            
            @inventory1 = create_inventory_with( { @supply => 100 }, Time.zone.parse("2009-01-01") ) # generate a stock_input  with quantity at 100
            @inventory2 = create_inventory_with( { @supply => 70 },  Time.zone.parse("2009-02-01") ) # generate a stock_output with quantity at 30
            @inventory3 = create_inventory_with( { @supply => 70 },  Time.zone.parse("2009-03-01") ) # don't generate any stock_flow
            @inventory4 = create_inventory_with( { @supply => 300 }, Time.zone.parse("2009-04-01") ) # generate a stock_input  with quantity at 230
            @inventory5 = create_inventory_with( { @supply => 0 },   Time.zone.parse("2009-05-01") ) # generate a stock_output with quantity at 300
            @inventory6 = create_inventory_with( { @supply => 500 }, Time.zone.parse("2009-06-01") ) # generate a stock_input  with quantity at 500
            
            @stock_flow1 = @inventory1.stock_flows.detect{ |s| s.supply_id == @supply.id }
            @stock_flow2 = @inventory2.stock_flows.detect{ |s| s.supply_id == @supply.id }
            @stock_flow4 = @inventory4.stock_flows.detect{ |s| s.supply_id == @supply.id }
            @stock_flow5 = @inventory5.stock_flows.detect{ |s| s.supply_id == @supply.id }
            @stock_flow6 = @inventory6.stock_flows.detect{ |s| s.supply_id == @supply.id }
            
            flunk "@stock_flow1 should be created with good quantity" unless @stock_flow1 and @stock_flow1.quantity == 100
            flunk "@stock_flow2 should be created with good quantity" unless @stock_flow2 and @stock_flow2.quantity == 30
            flunk "@stock_flow4 should be created with good quantity" unless @stock_flow4 and @stock_flow4.quantity == 230
            flunk "@stock_flow5 should be created with good quantity" unless @stock_flow5 and @stock_flow5.quantity == 300
            flunk "@stock_flow6 should be created with good quantity" unless @stock_flow6 and @stock_flow6.quantity == 500
            
            flunk "@inventory3 should have no stock_flows" unless @inventory3.stock_flows.empty?
          end
          
          # test last_inventory
          should "have a last_inventory from now" do
            assert_equal @inventory6, @supply.last_inventory
          end
          
          should "have a last_inventory from 15th February 2009" do
            assert_equal @inventory2, @supply.last_inventory(Time.zone.parse("2009-02-15"))
          end
          
          should "NOT have a last_inventory from 31th December 2008" do
            assert_nil @supply.last_inventory(Time.zone.parse("2008-12-31"))
          end
          
          
          # test last_inventory_stock_flow
          should "have a last_inventory_stock_flow from now" do
            assert_equal @stock_flow6, @supply.last_inventory_stock_flow
          end
          
          should "have a last_inventory_stock_flow from 15th February 2009" do
            assert_equal @stock_flow2, @supply.last_inventory_stock_flow(Time.zone.parse("2009-02-15"))
          end
          
          should "NOT have a last_inventory_stock_flow from 31th December 2008" do
            assert_nil @supply.last_inventory_stock_flow(Time.zone.parse("2008-12-31"))
          end
        end
        
        context "which is saved and have many inventories and stock_flows" do
          setup do
            @supply.attributes = { :supply_sub_category_id => @supply_sub_category_type.first.id, :name => "Supply" }
            @supply.save!
            
            @inventory1   = create_inventory_with( { @supply => 100 }, Time.zone.parse("2009-01-01") )            # generate a stock_input  with quantity at 100  => stock_quantity = 100
            @stock_input1 = create_stock_input_for_supply(@supply, :unit_price => 100,
                                                                   :quantity   => 100,
                                                                   :created_at => Time.zone.parse("2009-01-15"))  # generate a stock_input  with quantity at 100  => stock_quantity = 200
            @inventory2   = create_inventory_with( { @supply => 70 },  Time.zone.parse("2009-02-01") )            # generate a stock_output with quantity at 130  => stock_quantity = 70
            @stock_input2 = create_stock_input_for_supply(@supply, :unit_price => 100,
                                                                   :quantity   => 100,
                                                                   :created_at => Time.zone.parse("2009-02-15"))  # generate a stock_input  with quantity at 100  => stock_quantity = 170
            @inventory3 = create_inventory_with( { @supply => 170 }, Time.zone.parse("2009-03-01") )              # don't generate any stock_flow                 => stock_quantity = 170
            @inventory4 = create_inventory_with( { @supply => 200 }, Time.zone.parse("2009-04-01") )              # generate a stock_input  with quantity at 30   => stock_quantity = 200
            @inventory5 = create_inventory_with( { @supply => 200 }, Time.zone.parse("2009-05-01") )              # don't generate any stock_flow                 => stock_quantity = 200
            
            @stock_flow1 = @inventory1.stock_flows.detect{ |s| s.supply_id == @supply.id }
            @stock_flow2 = @inventory2.stock_flows.detect{ |s| s.supply_id == @supply.id }
            @stock_flow4 = @inventory4.stock_flows.detect{ |s| s.supply_id == @supply.id }
            
            flunk "@stock_input1 should be created with good quantity" unless @stock_input1 and @stock_input1.quantity == 100
            flunk "@stock_input2 should be created with good quantity" unless @stock_input2 and @stock_input2.quantity == 100
            
            flunk "@stock_flow1 should be created with good quantity" unless @stock_flow1 and @stock_flow1.quantity == 100
            flunk "@stock_flow2 should be created with good quantity" unless @stock_flow2 and @stock_flow2.quantity == 130
            flunk "@stock_flow4 should be created with good quantity" unless @stock_flow4 and @stock_flow4.quantity == 30
            
            flunk "@inventory3 should have no stock_flows" unless @inventory3.stock_flows.empty?
            flunk "@inventory5 should have no stock_flows" unless @inventory5.stock_flows.empty?
          end
          
          # test last_inventory_stock_flow
          should "return good last_inventory_stock_flow even if last_inventory doesn't imply the supply" do
            assert_equal @stock_input2, @supply.last_inventory_stock_flow(Time.zone.parse("2009-03-02"))
          end
          
          should "return good last_inventory_stock_flow even if last_inventory doesn't imply the supply but previous inventory does" do
            # @stock_flow4 is generated by the inventory4, which is the previous inventory against the last_inventory
            assert_equal @stock_flow4, @supply.last_inventory_stock_flow(Time.zone.parse("2009-05-02"))
          end
          
          
          # test stock_quantity
          should "have a good stock_quantity when given date is NOW" do
            assert_equal 200, @supply.stock_quantity
          end
          
          should "have a good stock_quantity when given date is after an inventory which doesn't imply the supply" do
            assert_equal 170, @supply.stock_quantity(Time.zone.parse("2009-03-02"))
          end
          
          should "have a good stock_quantity when given date is after an inventory which imply the supply" do
            assert_equal 200, @supply.stock_quantity(Time.zone.parse("2009-04-02"))
          end
          
          should "have a good stock_quantity when given date is after a stock_flow which imply the supply" do
            assert_equal 200, @supply.stock_quantity(Time.zone.parse("2009-01-16"))
          end
          
          should "have a stock_quantity at 0 when given date is before all stock_flows" do
            assert_equal 0, @supply.stock_quantity(Time.zone.parse("2008-12-31"))
          end
          
          
          # test stock_quantity_at_last_inventory
          should "have a good stock_quantity_at_last_inventory when given date is NOW" do
            assert_equal 200, @supply.stock_quantity_at_last_inventory
          end
          
          should "have a good stock_quantity_at_last_inventory when given date is after an inventory which doesn't imply the supply" do
            assert_equal 170, @supply.stock_quantity_at_last_inventory(Time.zone.parse("2009-03-02"))
          end
          
          should "have a good stock_quantity_at_last_inventory when given date is after an inventory which imply the supply" do
            assert_equal 70, @supply.stock_quantity_at_last_inventory(Time.zone.parse("2009-02-02"))
          end
          
          should "have a good stock_quantity_at_last_inventory when given date is after a 'normal' stock_flow" do # normal <=> from_inventory
            assert_equal 70, @supply.stock_quantity_at_last_inventory(Time.zone.parse("2009-02-16"))
          end
          
          should "have a stock_quantity_at_last_inventory at 0 when given date is before all stock_flows" do
            assert_equal 0, @supply.stock_quantity_at_last_inventory(Time.zone.parse("2008-12-31"))
          end
        end
        
        context "which is saved and have many stock_inputs and stock_outputs" do
          setup do
            @supply.attributes = { :supply_sub_category_id => @supply_sub_category_type.first.id, :name => "Supply", :measure => 5, :unit_mass => 15 }
            @supply.save!
            
            @stock_input1   = create_stock_input_for_supply( @supply, :unit_price => 100,                                         # stock_value               => 0 + ( 50 * 100 ) = 5000
                                                                      :quantity   => 50,                                          # stock_quantity            => 50
                                                                      :created_at => Time.zone.parse("2009-01-01"))               # average_unit_stock_value  => 100
            flunk "@stock_input1 should be created with good quantity" unless @stock_input1 and @stock_input1.quantity == 50      
            
            @stock_output1  = create_stock_output_for_supply(@supply, :quantity   => 10,                                          # stock_value               => 5000 - ( 10 * 100 ) = 4000
                                                                      :created_at => Time.zone.parse("2009-02-01"))               # stock_quantity            => 40
                                                                                                                                  # average_unit_stock_value  => 100
            flunk "@stock_output1 should be created with good quantity" unless @stock_output1 and @stock_output1.quantity == 10
            
            @stock_input2   = create_stock_input_for_supply( @supply, :unit_price => 100,                                         # stock_value               => 4000 + ( 100 * 100 ) = 14000
                                                                      :quantity   => 100,                                         # stock_quantity            => 140
                                                                      :created_at => Time.zone.parse("2009-03-01"))               # average_unit_stock_value  => 100
            flunk "@stock_input2 should be created with good quantity" unless @stock_input2 and @stock_input2.quantity == 100
            
            @stock_output2  = create_stock_output_for_supply(@supply, :quantity   => 140,                                         # stock_value               => 14000 - ( 140 * 100 ) = 0
                                                                      :created_at => Time.zone.parse("2009-04-01"))               # stock_quantity            => 0
                                                                                                                                  # average_unit_stock_value  => 0
            flunk "@stock_output2 should be created with good quantity" unless @stock_output2 and @stock_output2.quantity == 140
            
            @stock_input3   = create_stock_input_for_supply( @supply, :unit_price => 100,                                         # stock_value               => 0 + ( 200 * 100 ) = 20000
                                                                      :quantity   => 200,                                         # stock_quantity            => 200
                                                                      :created_at => Time.zone.parse("2009-05-01"))               # average_unit_stock_value  => 100
            flunk "@stock_input3 should be created with good quantity" unless @stock_input3 and @stock_input3.quantity == 200
            
            @stock_output3  = create_stock_output_for_supply(@supply, :quantity   => 100,                                         # stock_value               => 20000 - ( 100 * 100 ) = 10000
                                                                      :created_at => Time.zone.parse("2009-06-01"))               # stock_quantity            => 100
                                                                                                                                  # average_unit_stock_value  => 100
            flunk "@stock_output3 should be created with good quantity" unless @stock_output3 and @stock_output3.quantity == 100
          end
          
          # test stock_value
          should "have a good stock_value when given date is NOW" do
            assert_equal BigDecimal.new("10000"), @supply.stock_value
          end
          
          should "have a good stock_value when given date is after a stock_flow" do
            assert_equal BigDecimal.new("20000"), @supply.stock_value(Time.zone.parse("2009-05-02"))
          end
          
          should "have a good stock_value when given date is before all stock_flows" do
            assert_equal 0, @supply.stock_value(Time.zone.parse("2008-12-31"))
          end
          
          should "have a stock_value at 0 when given date is after a stock_output which put stock_quantity at 0" do
            assert_equal BigDecimal.new("0"), @supply.stock_value(Time.zone.parse("2009-04-02"))
          end
          
          
          # test stock_measure
          should "have a good stock_measure when given date is NOW" do
            expected_value = BigDecimal.new("500") # stock_quantity * measure => 100 * 5 = 500
            assert_equal expected_value, @supply.stock_measure
          end
          
          should "have a good stock_measure when given date is after a stock_flow" do
            expected_value = BigDecimal.new("200") # stock_quantity * measure => 40 * 5 = 200
            assert_equal expected_value, @supply.stock_measure(Time.zone.parse("2009-02-02"))
          end
          
          should "have a good stock_measure when given date is before all stock_flows" do
            assert_equal 0, @supply.stock_measure(Time.zone.parse("2008-12-31"))
          end
          
          should "have a stock_measure at 0 when given date is after a stock_output which put stock_quantity at 0" do
            assert_equal BigDecimal.new("0"), @supply.stock_measure(Time.zone.parse("2009-04-02"))
          end
          
          
          # test stock_mass
          should "have a good stock_mass when given date is NOW" do
            expected_value = BigDecimal.new("1500") # stock_quantity * mass => 100 * 15 = 1500
            assert_equal expected_value, @supply.stock_mass
          end
          
          should "have a good stock_mass when given date is after a stock_flow" do
            expected_value = BigDecimal.new("600") # stock_quantity * mass => 40 * 15 = 600
            assert_equal expected_value, @supply.stock_mass(Time.zone.parse("2009-02-02"))
          end
          
          should "have a good stock_mass when given date is before all stock_flows" do
            assert_equal 0, @supply.stock_mass(Time.zone.parse("2008-12-31"))
          end
          
          should "have a stock_mass at 0 when given date is after a stock_output which put stock_quantity at 0" do
            assert_equal BigDecimal.new("0"), @supply.stock_mass(Time.zone.parse("2009-04-02"))
          end
          
        end
        
        context "which is saved and have many stock_inputs and stock_outputs with different unit_price" do
          setup do
            @supply.attributes = { :supply_sub_category_id => @supply_sub_category_type.first.id, :name => "Supply" }
            @supply.save!
            
            @stock_input1   = create_stock_input_for_supply( @supply, :unit_price => 100,                                         # stock_value               => 0 + ( 50 * 100 ) = 5000
                                                                      :quantity   => 50,                                          # stock_quantity            => 50
                                                                      :created_at => Time.zone.parse("2009-01-01"))                    # average_unit_stock_value  => 100
            flunk "@stock_input1 should be created with good quantity" unless @stock_input1 and @stock_input1.quantity == 50      
            
            @stock_output1  = create_stock_output_for_supply(@supply, :quantity   => 10,                                          # stock_value               => 5000 - ( 10 * 100 ) = 4000
                                                                      :created_at => Time.zone.parse("2009-02-01"))                    # stock_quantity            => 40
                                                                                                                                  # average_unit_stock_value  => 100
            flunk "@stock_output1 should be created with good quantity" unless @stock_output1 and @stock_output1.quantity == 10
            
            @stock_input2   = create_stock_input_for_supply( @supply, :unit_price => 120,                                         # stock_value               => 4000 + ( 100 * 120 ) = 16000
                                                                      :quantity   => 100,                                         # stock_quantity            => 140
                                                                      :created_at => Time.zone.parse("2009-03-01"))                    # average_unit_stock_value  => 16000 / 140 = 114.285714286
            flunk "@stock_input2 should be created with good quantity" unless @stock_input2 and @stock_input2.quantity == 100
            
            @stock_output2  = create_stock_output_for_supply(@supply, :quantity   => 140,                                         # stock_value               => 16000 - ( 140 * 114.285714286 ) = −0.00000004 ~= 0
                                                                      :created_at => Time.zone.parse("2009-04-01"))                    # stock_quantity            => 0
                                                                                                                                  # average_unit_stock_value  => 0
            flunk "@stock_output2 should be created with good quantity" unless @stock_output2 and @stock_output2.quantity == 140
            
            @stock_input3   = create_stock_input_for_supply( @supply, :unit_price => 150,                                         # stock_value               => 0 + ( 200 * 150 ) = 30000
                                                                      :quantity   => 200,                                         # stock_quantity            => 200
                                                                      :created_at => Time.zone.parse("2009-05-01"))                    # average_unit_stock_value  => 150
            flunk "@stock_input3 should be created with good quantity" unless @stock_input3 and @stock_input3.quantity == 200
            
            @stock_output3  = create_stock_output_for_supply(@supply, :quantity   => 100,                                         # stock_value               => 30000 - ( 100 * 150 ) = 15000
                                                                      :created_at => Time.zone.parse("2009-06-01"))                    # stock_quantity            => 100
                                                                                                                                  # average_unit_stock_value  => 150
            flunk "@stock_output3 should be created with good quantity" unless @stock_output3 and @stock_output3.quantity == 100
          end
          
          # test stock_quantity
          should "have a good stock_quantity when given date is NOW" do
            assert_equal 100, @supply.stock_quantity
          end
          
          should "have a good stock_quantity when given date is after a stock_flow" do
            assert_equal 200, @supply.stock_quantity(Time.zone.parse("2009-05-02"))
          end
          
          should "have a good stock_quantity when given date is before all stock_flows" do
            assert_equal 0, @supply.stock_quantity(Time.zone.parse("2008-12-31"))
          end
          
          should "have a stock_quantity at 0 when given date is after a stock_output which put stock_quantity at 0" do
            assert_equal 0, @supply.stock_quantity(Time.zone.parse("2009-04-02"))
          end
          
          
          # test stock_value
          should "have a good stock_value when given date is NOW" do
            assert_equal BigDecimal.new("15000"), @supply.stock_value
          end
          
          should "have a good stock_value when given date is after a stock_flow" do
            assert_equal BigDecimal.new("30000"), @supply.stock_value(Time.zone.parse("2009-05-02"))
          end
          
          should "have a good stock_value when given date is before all stock_flows" do
            assert_equal 0.0, @supply.stock_value(Time.zone.parse("2008-12-31"))
          end
          
          should "have a stock_value at 0 when given date is after a stock_output which put stock_quantity at 0" do
            assert_equal 0.0, @supply.stock_value(Time.zone.parse("2009-04-02"))
          end
          
          
          # test average_unit_stock_value
          should "have a good average_unit_stock_value when given date is NOW" do
            assert_equal 150, @supply.average_unit_stock_value
          end
          
          should "have a good average_unit_stock_value when given date is after a stock_flow" do
            assert_equal 150, @supply.average_unit_stock_value(Time.zone.parse("2009-05-02"))
          end
          
          should "have a good average_unit_stock_value when given date is before all stock_flows" do
            assert_equal 0.0, @supply.average_unit_stock_value(Time.zone.parse("2008-12-31"))
          end
          
          should "have a average_unit_stock_value at 0 when given date is after a stock_output which put stock_quantity at 0" do
            assert_equal 0.0, @supply.average_unit_stock_value(Time.zone.parse("2008-04-02"))
          end
        end
        
        context "without supplier_supply" do
          setup do
            @supply.attributes = { :supply_sub_category_id      => @supply_sub_category_type.first.id,
                                   :name                        => "Supply" }
            @supply.save!
          end
          
          should "NOT have supplier_supplies_unit_prices" do
            assert_equal [], @supply.supplier_supplies_unit_prices
          end
          
          should "NOT have an average_unit_price" do
            assert_nil @supply.average_unit_price
          end
          
          should "NOT have an average_measure_price" do
            assert_nil @supply.average_measure_price
          end
          
          should "have an higher_unit_price" do
            assert_nil @supply.higher_unit_price
          end
          
          should "NOT have an higher_measure_price" do
            assert_nil @supply.higher_measure_price
          end
        end
        
        context "with 1 supplier_supply" do
          setup do
            @supply.attributes = { :supply_sub_category_id      => @supply_sub_category_type.first.id,
                                   :name                        => "Supply",
                                   :supplier_supply_attributes  => [ { :supplier_id     => thirds(:first_supplier).id,
                                                                       :fob_unit_price  => 100,
                                                                       :taxes           => 10 } ] }
            @supply.save!
            
            flunk "@supply should have 1 supplier_supply" unless @supply.supplier_supplies.count == 1
          end
          
          should "have supplier_supplies_unit_prices" do
            expected_value = [ 110 ] # unit_price = fob_unit_price * ( 1 + ( taxes / 100 ) ) <=> 100 * ( 1 + 0.1 ) = 110
            assert_equal expected_value, @supply.supplier_supplies_unit_prices
          end
          
          should "have an average_unit_price" do
            expected_value = 110 # supplier_supplies_unit_prices.sum / supplier_supplies.size <=> 110 / 1 = 110
            assert_equal expected_value, @supply.average_unit_price
          end
          
          should "NOT have an average_measure_price" do
            assert_nil @supply.average_measure_price
          end
          
          should "have an higher_unit_price" do
            expected_value = 110 # supplier_supplies_unit_prices.max = 110
            assert_equal expected_value, @supply.higher_unit_price
          end
          
          should "NOT have an higher_measure_price" do
            assert_nil @supply.higher_measure_price
          end
          
          context "and with a measure" do
            setup do
              @supply.measure = 5
              @supply.save!
            end
            
            should "have an average_measure_price" do
              expected_value = 22 # average_measure_price / measure <=> 110 / 5 = 22
              assert_equal expected_value, @supply.average_measure_price
            end
            
            should "have an higher_measure_price" do
              expected_value = 22 # higher_unit_price / measure <=> 110 / 5 = 22
              assert_equal expected_value, @supply.higher_measure_price
            end
          end
        end
        
        context "with many supplier_supplies" do
          setup do
            @supply.attributes = { :supply_sub_category_id => @supply_sub_category_type.first.id,
                                   :name => "Supply",
                                   :supplier_supply_attributes  => [ { :supplier_id     => thirds(:first_supplier).id,
                                                                       :fob_unit_price  => 100,
                                                                       :taxes           => 10 },
                                                                     { :supplier_id     => thirds(:second_supplier).id,
                                                                       :fob_unit_price  => 100,
                                                                       :taxes           => 8 },
                                                                     { :supplier_id     => thirds(:third_supplier).id,
                                                                       :fob_unit_price  => 130,
                                                                       :taxes           => 0 } ] }
            @supply.save!
            
            flunk "@supply should have 3 supplier_supplies" unless @supply.supplier_supplies.count == 3
          end
          
          should "have supplier_supplies_unit_prices" do
            expected_value = [ 110, 108, 130 ] # unit_price = fob_unit_price * ( 1 + ( taxes / 100 ) ) <=> 100 * ( 1 + 0.1 ) = 110
            assert_equal expected_value, @supply.supplier_supplies_unit_prices
          end
          
          should "have an average_unit_price" do
            expected_value = 116 # supplier_supplies_unit_prices.sum / supplier_supplies.size <=> (110 + 108 + 130) / 3 = 348 / 3 = 116
            assert_equal expected_value, @supply.average_unit_price
          end
          
          should "NOT have an average_measure_price" do
            assert_nil @supply.average_measure_price
          end
          
          should "have an higher_unit_price" do
            expected_value = 130 # supplier_supplies_unit_prices.max = 130
            assert_equal expected_value, @supply.higher_unit_price
          end
          
          should "NOT have an higher_measure_price" do
            assert_nil @supply.higher_measure_price
          end
          
          context "and with a measure" do
            setup do
              @supply.measure = 5
              @supply.save!
            end
            
            should "have an average_measure_price" do
              expected_value = 23.2 # average_unit_price / measure <=> 116 / 5 = 23.2
              assert_equal expected_value, @supply.average_measure_price
            end
            
            should "have an higher_measure_price" do
              expected_value = 26 # higher_unit_price / measure <=> 130 / 5 = 26
              assert_equal expected_value, @supply.higher_measure_price
            end
          end
        end
        
      end
    end
  end
end
