require 'test_helper'

class MenuTest < ActiveSupport::TestCase
  fixtures :menus

  def setup
    @feature = features(:normal_feature1)
    @menu_one = menus(:menu_one)
    @menu_two = menus(:menu_two)
    @menu_three = menus(:menu_three)
    @menu_four = menus(:menu_four)
  end

  def test_create
    assert_difference 'Feature.count', +1 do
      assert Menu.create(:title => "Menu Test",
                        :description => "Test for menu creation",
                        :name => "test_menu",
                        :feature_id => @feature.id)
    end
  end

  def test_read
    assert_nothing_raised "A Menu should be read" do
      Menu.find_by_name(@menu_one.name)
    end
  end

  def test_update
    assert @menu_one.update_attributes(:title => 'New Title'), "A Menu should be updated"
  end

  def test_ability_to_delete
    # TODO
  end

  def test_delete
    assert_difference 'Feature.count', -1 do
      @menu_one.destroy
    end
  end

  def test_prescence_of_title
    @menu_one.update_attributes(:title => '')
    assert_not_nil @menu_one.errors.on(:title), "A Menu should have a title"
  end

  def test_prescence_of_name
    @menu_one.update_attributes(:name => '')
    assert_not_nil @menu_one.errors.on(:name), "A Menu should have a name"
  end

  def test_parent
    # TODO
  end

  def test_children_menu
    # TODO
  end

  def test_siblings_activated
    # TODO
  end

  def test_change_parent
    # TODO
  end

  def move_up
    # TODO
  end

  def move_down
    # TODO
  end
end
