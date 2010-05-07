module HasContactsTest
  
  # This module shoul be implemented into the calling classe's test suite
  #
  #
  # SAMPLE
  #
  #  context "have many contacts" do
  #    setup do
  #      @contacts_owner       = ... 
  #    end
  #    
  #    include HasContactsTest
  #  end
  #
  #  @contacts_owner should: 
  #  - Be the only one variable depending on the calling class.
  #  - Return a valid instance of the calling class.
  #
  class << self
    def included base
      base.class_eval do
        
        context "for @contacts_owner it" do # this is just for declare specific setup and teardown
          setup do
            flunk "@contacts_owner should exist" unless @contacts_owner
          end
          
          teardown do
          end
          
          subject { @contacts_owner }
          
          should_have_many :contacts
        end
        
      end
    end
  end


end
