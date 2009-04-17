require 'test_helper'

class FamilySituationTest < ActiveSupport::TestCase
  def setup
    @family_situation = FamilySituation.create(:name => 'single')
  end
  
  def test_presence_of_name
    assert_no_difference 'FamilySituation.count' do
      family_situation = FamilySituation.create
      assert_not_nil family_situation.errors.on(:name), "A FamilySituation should have a name"
    end
  end
  
  def test_uniqness_of_name
    assert_no_difference 'FamilySituation.count' do
      family_situation = FamilySituation.create(:name => @family_situation.name)
      assert_not_nil family_situation.errors.on(:name), "A FamilySituation should have an uniq name"
    end
  end
end
