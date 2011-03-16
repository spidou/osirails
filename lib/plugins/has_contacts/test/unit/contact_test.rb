require 'test/test_helper'

class MockObject
end

class ContactTest < ActiveSupport::TestCase
  #TODO test has_permissions :as_business_object, :additional_class_methods => [ :hide ]
  
  #TODO test has_numbers
  
  should_belong_to :has_contact
  
  should_validate_presence_of :has_contact, :first_name, :last_name, :gender
  
  should_allow_values_for :email, nil, "", "foo@bar.com"
  should_not_allow_values_for :email, 1, "foo", "bar.com", "f.@bar.com", "foo@bar.c"
  
  should_allow_values_for :gender, "M", "F"
  should_not_allow_values_for :gender, nil, "", 1, "anything"
  
  should_journalize :attributes        => [ :gender, :first_name, :last_name, :job, :email ],
                    :subresources      => [ :numbers ],
                    :attachments       => :avatar,
                    :identifier_method => :fullname
  
  context "A new contact" do
    setup do
      @contact = Contact.new
    end
    
    should "not be able to be hidden" do
      assert !@contact.can_be_hidden?
    end
    
    should "not be hidden" do
      @contact.hide
      assert !@contact.hidden_was
    end
  end
  
  context "A contact" do
    setup do
      o = MockObject.new
      o.expects(:new_record?).returns(false)
      MockObject.expects(:find).with(1, {:include => nil, :select => nil}).returns(o)
      
      @contact = Contact.create! :has_contact_type  => "MockObject",
                                 :has_contact_id    => "1",
                                 :first_name        => "Pierre Paul",
                                 :last_name         => "Jacques",
                                 :job               => "Commercial",
                                 :email             => "pierre_paul@jacques.com",
                                 :gender            => "M"
    end
    
    context "which has been modified" do
      setup do
        @contact.last_name = nil
      end
      
      should "be marked to be saved" do
        assert @contact.should_save?
      end
    end
    
    context "which has been marked to be updated" do
      setup do
        @contact.should_update = 1
      end
      
      should "be marked to be saved" do
        assert @contact.should_save?
      end
    end
    
    context "which has been marked to be hidden" do
      setup do
        @contact.should_hide = 1
      end
      
      should "be marked to be saved" do
        assert @contact.should_save?
      end
    end
    
    context "which has been marked to be destroyed" do
      setup do
        @contact.should_destroy = 1
      end
      
      should "be marked to be saved" do
        assert @contact.should_save?
      end
    end
  end
end
