module HasContactsTest
  
  # This module shoul be implemented into the calling classe's test suite
  #
  # ==== Example
  #  context "Thanks to has_contacts, an establishment" do
  #    setup do
  #      @contacts_owner = Establishment.new
  #    end
  #    
  #    include HasContactsTest
  #  end
  #
  #  @contacts_owner should be a valid instance of a class which call 'has_contacts'
  #
  class << self
    def included base
      base.class_eval do
        
        should_have_many :contacts
        
        should "fill the array 'Contact.contacts_owners_models'" do
          assert Contact.contacts_owners_models.include?(@contacts_owner.class.name)
        end
        
        should "respond to contact_attributes=" do
          assert @contacts_owner.respond_to?(:contact_attributes=)
        end
        
        should "respond to save_contacts" do
          assert @contacts_owner.respond_to?(:save_contacts), @contact_owners.inspect
        end
      end
    end
  end


end
