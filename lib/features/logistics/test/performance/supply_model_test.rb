#require 'test_helper'
require File.dirname(__FILE__) + '/../logistics_test'
require 'performance_test_help'

class SupplyModelTest < ActionController::PerformanceTest
  def test_find_supplies_without_includes
    define_conditions
    fetching_records(find_supplies_without_includes)
  end
  
  def test_find_supplies_including_supply_type
    define_conditions
    fetching_records(find_supplies_including_supply_type)
  end
  
  def test_find_supplies_including_supplies_supply_sizes
    define_conditions
    fetching_records(find_supplies_including_supplies_supply_sizes)
  end
  
  def test_find_supplies_including_supplier_supplies
    define_conditions
    fetching_records(find_supplies_including_supplier_supplies)
  end
  
  def test_find_supplies_including_supply_type_and_supplies_supply_sizes
    define_conditions
    fetching_records(find_supplies_including_supply_type_and_supplies_supply_sizes)
  end
  
  def test_find_supplies_including_supply_type_and_supplier_supplies
    define_conditions
    fetching_records(find_supplies_including_supply_type_and_supplier_supplies)
  end
  
  def test_find_supplies_including_supplies_supply_sizes_and_supplier_supplies
    define_conditions
    fetching_records(find_supplies_including_supplies_supply_sizes_and_supplier_supplies)
  end
  
  def test_find_supplies_including_all
    define_conditions
    fetching_records(find_supplies_including_all)
  end
  
  private
    def load_fixtures
      return if @fixtures_loaded == true
      
      Commodity.destroy_all
      CommodityType.destroy_all
      CommoditySubCategory.destroy_all
      CommodityCategory.destroy_all
      
      3.times do |i|
        category = CommodityCategory.create!(:name => "Category #{i}")
        4.times do |j|
          sub_category = CommoditySubCategory.create!(:supply_category_id => category.id, :name => "Sub Category #{i} > #{j}")
          5.times do |k|
            CommodityType.create!(:supply_category_id => sub_category.id, :name => "Type #{i} > #{j} > #{k}")
          end
        end
      end
      
      SupplyType.all.each do |supply_type|
        create_default_supply(:supply_type_id => supply_type.id)
      end
      
      @fixtures_loaded = true
    end
    
    def define_conditions
      @conditions = nil#["(supplies.reference like ? OR supply_categories.name like ? OR supply_sub_categories_supply_categories.name like ? OR supply_categories_supply_categories.name like ? OR supplies_supply_sizes.value like ? OR unit_measures.symbol like ?)", "%a%", "%a%", "%a%", "%a%", "%a%", "%a%"]
    end
    
    def fetching_records(records)
      records.each do |r|
        r.id
        r.designation(true)
        r.unit_price
        r.unit_measure && r.unit_measure.symbol
        r.measure_price
      end
    end
    
    def find_supplies_without_includes
      Commodity.all(:conditions => @conditions)
    end
    
    def find_supplies_including_supply_type
      Commodity.all(:include => [ { :supply_type => { :supply_sub_category => [:supply_category] } } ], :conditions => @conditions)
    end
    
    def find_supplies_including_supplies_supply_sizes
      Commodity.all(:include => [ { :supplies_supply_sizes => [:unit_measure] } ], :conditions => @conditions)
    end
    
    def find_supplies_including_supplier_supplies
      Commodity.all(:include => [ :supplier_supplies ], :conditions => @conditions) 
    end
    
    def find_supplies_including_supply_type_and_supplies_supply_sizes
      Commodity.all(:include => [ { :supply_type => { :supply_sub_category => [:supply_category] } }, { :supplies_supply_sizes => [:unit_measure] } ], :conditions => @conditions)
    end
    
    def find_supplies_including_supply_type_and_supplier_supplies
      Commodity.all(:include => [ { :supply_type => { :supply_sub_category => [:supply_category] } }, :supplier_supplies ], :conditions => @conditions)
    end
    
    def find_supplies_including_supplies_supply_sizes_and_supplier_supplies
      Commodity.all(:include => [ { :supplies_supply_sizes => [:unit_measure] }, :supplier_supplies ], :conditions => @conditions)
    end
    
    def find_supplies_including_all
      Commodity.all(:include => [ { :supply_type => { :supply_sub_category => [:supply_category] } }, { :supplies_supply_sizes => [:unit_measure] }, :supplier_supplies ], :conditions => @conditions)
    end
end

=begin RESULTS
                                                                          With 6 records (ms) | With 60 records (ms)
test_find_supplies_including_all                                                           60 | 350*
test_find_supplies_including_supplier_supplies                                            *40 | 350*                  <-- winner (lower is better)
test_find_supplies_including_supplies_supply_sizes                                        *40 | 410
test_find_supplies_including_supplies_supply_sizes_and_supplier_supplies                   50 | 410
test_find_supplies_including_supply_type                                                   60 | 360
test_find_supplies_including_supply_type_and_supplier_supplies                            *40 | 360
test_find_supplies_including_supply_type_and_supplies_supply_sizes                         50 | 380
test_find_supplies_without_includes                                                       *40 | 380
=end
