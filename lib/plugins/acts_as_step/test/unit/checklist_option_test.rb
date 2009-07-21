require 'test_helper'

class ChecklistOptionTest < ActiveSupport::TestCase
  def setup
    @checklist = Checklist.create(:name => 'Level')
    @checklist_option_one = ChecklistOption.create(:name => 'High',
                                                   :checklist_id => @checklist.id)
    @checklist_option_two = ChecklistOption.create(:name => 'Medium',
                                                   :checklist_id => @checklist.id)
    @checklist_option_three = ChecklistOption.create(:name => 'Medium',
                                                     :checklist_id => @checklist.id)
  end

  def test_presence_of_name
    assert_no_difference 'ChecklistOption.count' do
      checklist_option = ChecklistOption.create
      assert_not_nil checklist_option.errors.on(:name), "A ChecklistOption should have a name"
    end
  end

  def test_presence_of_checklist_id
    assert_no_difference 'ChecklistOption.count' do
      checklist_option = ChecklistOption.create
      assert_not_nil checklist_option.errors.on(:checklist_id), "A ChecklistOption should have a checklist id"
    end
  end
end
