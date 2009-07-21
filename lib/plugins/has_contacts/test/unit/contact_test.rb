require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  def test_presence_of_first_name
    assert_no_difference 'Contact.count' do
      contact = Contact.create
      assert_not_nil contact.errors.on(:first_name), "A Contact should have a first name"
    end
  end
  
  def test_presence_of_last_name
    assert_no_difference 'Contact.count' do
      contact = Contact.create
      assert_not_nil contact.errors.on(:last_name), "A Contact should have a last name"
    end
  end
  
  def test_format_of_email
    assert_no_difference 'Contact.count' do
      contact = Contact.create(:email => 'foobar')
      assert_not_nil contact.errors.on(:email), "A Contact should have an email with a good foramt"
    end
  end
end
