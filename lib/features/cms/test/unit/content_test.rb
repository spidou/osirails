require File.dirname(__FILE__) + '/../cms_test'

class ContentTest < ActiveSupport::TestCase
  should_belong_to :menu, :author
  
  should_have_many :versions, :dependent => :destroy
  
  should_validate_presence_of :title
  
  def setup
    @content_one = contents(:normal_content)
    @content_one.update_attribute(:contributors, [users(:cms_first_user)])
  end

  def test_serialization_of_contributors
    @content_one.update_attributes(:contributors => [users(:cms_second_user), users(:cms_first_user)])
    assert_equal @content_one.contributors, [users(:cms_second_user), users(:cms_first_user)],
      "A Content should have contributors"
  end

  def test_multiple_same_contributors
    @content_one.update_attributes(:contributors => [users(:cms_second_user), users(:cms_second_user)])
    assert_equal @content_one.contributors, [users(:cms_second_user)],
      "A Content should not have multiple same contributor"
  end
end
