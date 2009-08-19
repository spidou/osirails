require 'test/test_helper'

class InventoryTest < ActiveSupport::TestCase
  fixtures :inventories, :commodities, :commodities_inventories

  def setup
    @inventory = inventories(:normal)
  end

  def test_has_many_commodities_inventories
    assert_equal @inventory.commodities_inventories, [commodities_inventories(:normal)],
      "This Inventory should have this CommoditiesInventory"
  end

  def test_has_many_commodities
    assert_equal @inventory.commodities, [commodities(:normal)],
      "This Inventory should have this Commodities"
  end

  def test_closed
    assert !@inventory.inventory_closed?, "This Inventory should not be closed"
  end

  def test_create_inventory
    assert_difference 'CommoditiesInventory.count', +1 do
      @inventory.create_inventory [commodities(:normal)]
    end
  end
end
