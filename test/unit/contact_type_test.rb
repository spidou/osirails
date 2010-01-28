require 'test/test_helper'

class ContactTypeTest < ActiveSupport::TestCase
  def test_presence_of_name
    assert_no_difference 'ContactType.count' do
      contact_type = ContactType.create
      assert_not_nil contact_type.errors.on(:name), "A ContactType should have a name"
    end
  end

  def test_presence_of_owner
    assert_no_difference 'ContactType.count' do
      contact_type = ContactType.create
      assert_not_nil contact_type.errors.on(:owner), "A ContactType should have an owner"
    end
  end
end
