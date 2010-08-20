require File.dirname(__FILE__) + '/../sales_test'

class GraphicUnitMeasureTest < ActiveSupport::TestCase
  should_have_many :graphic_items
  should_validate_presence_of :name, :symbol
  should_validate_uniqueness_of :name, :symbol
end
