require File.dirname(__FILE__) + '/../thirds_test'

class ConveyanceTest < ActiveSupport::TestCase
  should_have_many :forwarder_conveyances
  should_have_many :forwarders
  
  should_validate_presence_of :name
  
  context 'A conveyance' do
    setup do
      @conveyance = Conveyance.new(:name => "Avion")
      @conveyance.save!
    end
    
    subject{@conveyance}
    
    should_validate_uniqueness_of :name
  end
end
