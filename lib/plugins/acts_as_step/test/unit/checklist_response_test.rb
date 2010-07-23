require 'test/test_helper'

class ChecklistResponseTest < ActiveSupport::TestCase
  should_belong_to :checklist_option, :end_product
  should_validate_presence_of :answer
end
