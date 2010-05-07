module HasContactTest
  
  # This module shoul be implemented into the calling classe's test suite
  #
  #
  # SAMPLE
  #
  #  context "plugin has_contact :" do
  #    setup do
  #      @contact_owner = ...
  #      @contact_key   = ...
  #    end
  #    
  #    subject { @contact_owner }
  #          
  #    should_belong_to :CONTACT_KEY
  #    
  #    include HasContactTest
  #  end
  #
  #  @contact_owner should: 
  #  - Be the only one variable depending on the calling class.
  #  - Return a valid instance of the calling class.
  #  @contact_key should be the key passed to has_contact:
  #  ex:  has_contact :contact_key
  #
  class << self
    def included base
      base.class_eval do
        
        context "A @contact_owner" do # this is just to declare specific setup and teardown
          setup do
            flunk "@contact_owner and @contact_key should exist" unless @contact_owner and @contact_key
          end
        end
        
        should "have all_contacts" do
          assert_equal [ @contact_owner.send(@contact_key) ], @contact_owner.all_contacts
        end
        
      end
    end
  end


end
