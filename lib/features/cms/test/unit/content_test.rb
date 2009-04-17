require 'test_helper'

class ContentTest < ActiveSupport::TestCase
  fixtures :contents, :users, :menus

  def setup
    @content_one = contents(:one)
    @content_one.update_attributes(:menu_id => Menu.first.id,
                                   :author_id => User.first.id,
                                   :contributors => [User.last.id])
  end

  def test_read
    assert_nothing_raised "A Content should be read" do
      Content.find_by_title(@content_one.title)
    end
  end

  def test_update
    assert @content_one.update_attributes(:title => 'New title'), "A Content should be updated"                                               
  end

  def test_delete
    assert_difference 'Content.count', -1 do
      @content_one.destroy
    end
  end

  def test_presence_of_title
    assert_no_difference 'Content.count' do
      content = Content.create(:title => '')
      assert_not_nil content.errors.on(:title), "A Content should not have a blank title"
    end
  end

  def test_belongs_to_menu
    assert_equal @content_one.menu, Menu.first, "A Content should belongs to a Menu"
  end

  def test_belongs_to_author
    assert_equal @content_one.author, User.first, "A Content should belongs to an User"
  end

  def test_serialization_of_contributors
    @content_one.update_attributes(:contributors => [User.first, User.last])
    assert_equal @content_one.contributors, [User.first, User.last], "A Content should have contributors"
  end

  def test_multiple_same_contributors
    @content_one.update_attributes(:contributors => [User.first, User.first])
    assert_equal @content_one.contributors, [User.first], "A Content should not have multiple same contributor"
  end
end
