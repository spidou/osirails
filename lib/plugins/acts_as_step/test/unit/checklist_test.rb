require 'test/test_helper'

class ChecklistTest < ActiveSupport::TestCase
  should_have_many :checklist_options
end
