require File.dirname(__FILE__) + '/../thirds_test'

class ForwarderConveyanceTest < ActiveSupport::TestCase
  should_belong_to :forwarder, :conveyance
  should_validate_presence_of :conveyance, :with_foreign_key => :default
  
  
  context 'A forwarder_conveyance' do
    setup do
      @user = create_user
      @conveyance = Conveyance.new(:name => "Avion")
      @conveyance.save!
      @forwarder = create_forwarder
      @forwarder_conveyance = ForwarderConveyance.create!(:conveyance_id => @conveyance.id, :forwarder_id => @forwarder.id)
      flunk '@forwarder_conveyance should not be nil' unless @forwarder_conveyance
      flunk '@forwarder_conveyance should not be saved' if @forwarder_conveyance.new_record?
    end
    
    subject{@forwarder_conveyance}
    
    should_validate_uniqueness_of :conveyance_id, :scoped_to => :forwarder_id
  end
  
end
