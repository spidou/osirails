require 'test_helper'

class StepTest < ActiveSupport::TestCase
  def setup
    @step_parent = Step.create(:name => 'step_parent',
                               :title => 'Parent',
                               :position => 1)
    @step_one = Step.create(:name => 'step_one',
                           :title => 'One',
                           :position => 1,
                           :parent_id => @step_parent)
    @step_two = Step.create(:name => 'step_two',
                           :title => 'Two',
                           :position => 2,
                           :parent_id => @step_parent)
  end

  def test_presence_of_name
    assert_no_difference 'Step.count' do
      step = Step.create
      assert_not_nil step.errors.on(:name), "A Step should have a name"
    end
  end

  def test_presence_of_description
    assert_no_difference 'Step.count' do
      step = Step.create
      assert_not_nil step.errors.on(:description), "A Step should have a description"
    end
  end

  def test_first_parent
    assert_equal @step_one.first_parent, @step_parent, "This Step should have a parent"
    assert_equal @step_parent.first_parent, @step_parent, "This Step should not have a parent"
  end
end