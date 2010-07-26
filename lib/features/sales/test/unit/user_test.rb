require File.dirname(__FILE__) + '/../sales_test'

class UserTest < ActiveSupport::TestCase
  should_have_many :graphic_items, :graphic_item_spool_items
end
