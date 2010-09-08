module HasContactTest
  
  # This module shoul be implemented into the calling classe's test suite
  #
  # ==== Example
  #  context "Thanks to has_contact, a quote" do
  #    setup do
  #      @contact_owner = Quote.first
  #      @contact_keys  = [ :contact1, :contact2 ]
  #    end
  #    
  #    subject { @contact_owner }
  #          
  #    should_belong_to :contact1
  #    should_belong_to :contact2
  #    
  #    include HasContactTest
  #  end
  #
  #  @contact_owner should be a valid instance of a class which call 'has_contact'
  #  @contact_keys should be an array of keys passed to has_contact on a model
  #
  class << self
    def included base
      base.class_eval do
        
        context "which is a new_record" do
          setup do
            @contact_owner = @contact_owner.class.new
          end
          
          should "have 0 'all_contacts'" do
            assert_equal [], @contact_owner.all_contacts
          end
        end
        
        should "fill the array 'contact_keys' of the owner model" do
          assert_equal @contact_keys, @contact_owner.class.contact_keys
        end
        
        should "respond to all_contacts" do
          assert @contact_owner.respond_to?(:all_contacts)
        end
        
        should "respond to accept_contact_from_method" do
          assert @contact_owner.respond_to?(:accept_contact_from_method)
        end
        
        should "have an array as all_contacts" do
          assert @contact_owner.all_contacts.is_a?(Array)
        end
        
        should "have 'all_contacts'" do
          expected_contacts = @contact_keys.collect{ |key| @contact_owner.send(key) }.compact
          assert_equal expected_contacts, @contact_owner.all_contacts
        end
        
      end
    end
  end
  
end
