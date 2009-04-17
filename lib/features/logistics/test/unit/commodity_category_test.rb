require 'test_helper'

class CommodityCategoryTest < ActiveSupport::TestCase
  def setup
    @commodity_category = CommodityCategory.create(:name => 'test one')
    @commodity_category_with_parent = CommodityCategory.create(:name => 'test two', :commodity_category_id => @commodity_category.id)
  end

  def test_read
    assert_nothing_raised "A CommodityCategory should be read" do
      CommodityCategory.find_by_name(@commodity_category.name)
    end
  end

  def test_update
    assert @commodity_category.update_attributes(:name => 'new name'), "A CommodityCategory should be update"
  end

  def test_delete
    assert_difference 'CommodityCategory.count', -1 do
      @commodity_category_with_parent.destroy
    end
  end

  def test_recursiv_delete
    assert_difference 'CommodityCategory.count', -2 do
      @commodity_category.destroy
    end
  end

  def test_presence_of_name
    assert_no_difference 'CommodityCategory.count' do
      commodity_category = CommodityCategory.create
      assert_not_nil commodity_category.errors.on(:name), "A CommodityCategory should have a name"
    end
  end

  def test_ability_to_delete
    assert @commodity_category_with_parent.can_be_destroyed?, "This CommodityCategory should be deletable"
  end

  def test_unability_to_delete
    assert !@commodity_category.can_be_destroyed?, "This CommodityCategory should not be deletable"
  end

  def test_disabled_children
    assert !@commodity_category.has_children_disable?, "This CommodityCategory should not have disabled children"

    @commodity_category_with_parent.update_attributes(:enable => false)
    assert @commodity_category.has_children_disable?, "This CommodityCategory should have disabled children"
  end

  def test_parent_commodity_category
    assert_equal @commodity_category.commodity_categories, [@commodity_category_with_parent], "This CommodityCategory should have a child commodity category"
  end
end