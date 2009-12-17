require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'

class PressProofItemTest < ActiveSupport::TestCase
  fixtures :all
  
  should_belong_to :press_proof#, :graphic_item_version
end
