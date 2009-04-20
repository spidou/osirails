require 'test_helper'

class MenuTest < ActiveSupport::TestCase
  fixtures :menus

  def setup
    @feature = features(:normal_feature1)
    @menu_one = menus(:menu_one)
    @menu_two = menus(:menu_two)
    @menu_three = menus(:menu_three)
    @menu_four = menus(:menu_four)
    
    @menu_three.update_attributes(:parent_id => @menu_one.id, :position => 1)
    @menu_four.update_attributes(:parent_id => @menu_one.id, :position => 2)
  end

  def test_create
    assert_difference 'Menu.count', +1 do
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
    assert_difference 'Menu.count', -1 do
      @menu_two.destroy
    end
  end

  def test_recursiv_delete
    assert_difference 'Menu.count', -3 do
      @menu_one.destroy
    end
  end

  def test_presence_of_title
    @menu_one.update_attributes(:title => '')
    assert_not_nil @menu_one.errors.on(:title), "A Menu should have a title"
  end

  def test_parent
    assert_equal @menu_three.parent, @menu_one, "This Menu should have this parent"
  end

  def test_siblings_activated
    assert_equal 2, @menu_two.how_many_brother_activated('higher')
    assert_equal 1, @menu_two.how_many_brother_activated('lower')
  end

  def test_ability_to_have_this_parent
    assert !@menu_three.can_has_this_parent?(@menu_three), "A Menu should not have himself for parent"
    
    assert !@menu_one.can_has_this_parent?(@menu_three), "A Menu should not have a child for parent"
  end

  def test_change_parent
    @menu_three.change_parent(@menu_two.id)
    assert_equal @menu_three.parent, @menu_two, "This Menu should have this parent"
  end

  def move_up
    # TODO
  end

  def move_down
    # TODO
  end
end
