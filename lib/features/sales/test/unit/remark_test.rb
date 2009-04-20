require 'test_helper'

class RemarkTest < ActiveSupport::TestCase
  def test_presence_of_user_id
    assert_no_difference 'Remark.count' do
      remark = Remark.create
      assert_not_nil remark.errors.on(:user_id), "A Remark should have an user id"
    end
  end
end
