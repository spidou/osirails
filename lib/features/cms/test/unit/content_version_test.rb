require 'test/test_helper'

class ContentVersionTest < ActiveSupport::TestCase
  fixtures :contents
  
  def setup
    @content = contents(:one)
    @content_version = ContentVersion.create_from_content(@content)
  end
  
  def test_read
    assert_nothing_raised "ContentVersion should be read" do
      ContentVersion.find_by_title(@content_version.title)
    end
  end
  
  def test_content_version
    assert_equal @content.title, @content_version.title
    assert_equal @content.description, @content_version.description
    assert_equal @content.text, @content_version.text
    assert_equal @content.menu_id, @content_version.menu_id
    assert_equal @content.id, @content_version.content_id
    assert_equal @content.contributors.first, @content_version.contributor_id
  end
  
  def test_time_at_versionning
    assert @content_version.versioned_at?, "A ContentVersion should have a versioned time"
  end
  
  def test_delete
    assert_difference 'ContentVersion.count', -1 do
      @content_version.destroy
    end
  end
end
