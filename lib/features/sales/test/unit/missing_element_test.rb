require File.dirname(__FILE__) + '/../sales_test'

class MissingElementTest < ActiveSupport::TestCase
  should_belong_to :orders_steps
  should_validate_presence_of :name, :orders_steps_id
end
