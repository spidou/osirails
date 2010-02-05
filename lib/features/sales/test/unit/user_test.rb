require 'test/test_helper'

class UserTest < ActiveSupport::TestCase
  should_have_many :graphic_items, :graphic_item_spool_items
end
