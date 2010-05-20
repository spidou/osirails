require 'test/test_helper'

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
  
  context "A new contact" do
    setup do
      @contact = Contact.new
    end
    
    teardown do
      @contact = nil
    end
    
    should "not be able to be hidden" do
      assert !@contact.can_be_hidden?
    end
    
    should "not hide" do
      @contact.hide
      assert !@contact.hidden_was
    end
  end
  
  context "A contact.should_save?" do
    setup do
      @contact = contacts(:jean_dupond)
    end
    
    teardown do
      @contact = nil
    end
    
    should "be true when changed?" do
      @contact.last_name = nil
      assert @contact.should_save?
    end
    
    should "be true when should_update?" do
      @contact.should_update = 1
      assert @contact.should_save?
    end
    
    should "be true when should_hide?" do
      @contact.should_hide = 1
      assert @contact.should_save?
    end
    
    should "be true when should_destroy?" do
      @contact.should_destroy = 1
      assert @contact.should_save?
    end
  end
end
