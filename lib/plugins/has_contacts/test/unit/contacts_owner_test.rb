require 'test_helper'

class ContactsOwnerTest < ActiveSupport::TestCase
  def test_presence_of_contact_id
    assert_no_difference 'ContactsOwner.count' do
      contacts_owner = ContactsOwner.create
      assert_not_nil contacts_owner.errors.on(:contact_id), "A ContactsOwner should have a contact id"
    end
  end
end
