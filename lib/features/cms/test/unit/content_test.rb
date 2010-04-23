require 'test/test_helper'

class ContentTest < ActiveSupport::TestCase
  fixtures :contents, :users, :menus

  def setup
    @content_one = contents(:normal_content)
    @content_one.update_attribute(:contributors, [users(:admin_user)])
  end

  def test_read
    assert_nothing_raised "A Content should be read" do
      Content.find_by_title(@content_one.title)
    end
  end

  def test_update
    assert @content_one.update_attributes(:title => 'New title'),
      "A Content should be updated"                                               
  end

  def test_delete
    assert_difference 'Content.count', -1 do
      @content_one.destroy
    end
  end

  def test_presence_of_title
    assert_no_difference 'Content.count' do
      content = Content.create(:title => '')
      assert_not_nil content.errors.on(:title),
        "A Content should not have a blank title"
    end
  end

  def test_belongs_to_menu
    assert_equal @content_one.menu, menus(:menu_one),
      "A Content should belongs to a Menu"
  end

  def test_belongs_to_author
    assert_equal @content_one.author, users(:powerful_user),
      "A Content should belongs to an User"
  end

  def test_serialization_of_contributors
    @content_one.update_attributes(:contributors => [users(:powerful_user), users(:admin_user)])
    assert_equal @content_one.contributors, [users(:powerful_user), users(:admin_user)],
      "A Content should have contributors"
  end

  def test_multiple_same_contributors
    @content_one.update_attributes(:contributors => [users(:powerful_user), users(:powerful_user)])
    assert_equal @content_one.contributors, [users(:powerful_user)],
      "A Content should not have multiple same contributor"
  end
end
