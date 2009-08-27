require 'test/test_helper'

class CommodityInvetoryTest < ActiveSupport::TestCase
  fixtures :commodities_inventories, :inventories

  def test_belongs_to_inventory
    assert_equal commodities_inventories(:normal).inventory, inventories(:normal),
      "This CommodityInvetory should belongs to this Inventory"
  end
end
