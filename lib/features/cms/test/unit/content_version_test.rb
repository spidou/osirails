require File.dirname(__FILE__) + '/../cms_test'

class ContentVersionTest < ActiveSupport::TestCase
  
  should_belong_to :content, :contributor
  
  def setup
    @content = contents(:normal_content)
    @content_version = ContentVersion.create_from_content(@content)
  end
  subject{ @content_version }
  
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
  
end
