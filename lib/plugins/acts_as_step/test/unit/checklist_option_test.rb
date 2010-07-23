require File.dirname(__FILE__) + '/../acts_as_step_test'

class ChecklistOptionTest < ActiveSupport::TestCase
  should_belong_to :checklist
  
  should_have_many :checklist_options_order_types
  should_have_many :order_types, :through => :checklist_options_order_types
end
