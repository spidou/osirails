require File.dirname(__FILE__) + '/../thirds_test'

class DepartureTest < ActiveSupport::TestCase
  should_belong_to :forwarder
  
  should_validate_presence_of :city_name, :country_name
  
  context 'A departure associated to a new forwarder' do
    setup do
      @forwarder = Forwarder.new
      @departure = @forwarder.departures.build
    end
    
    should 'NOT be able to be hidden' do
      assert !@departure.can_be_hidden?
    end
    
    should 'NOT be able to be destroyed' do
      assert !@departure.can_be_destroyed?
    end
  end
  
  context 'A departure associated to a forwarder' do
    setup do
      @forwarder = create_forwarder
      flunk '@forwarder should not have departures yet' unless @forwarder.departures.empty?
      
      @forwarder.departures.build(:city_name => "Sydney", :country_name => "Australia")
      @forwarder.save!
      flunk '@forwarder should have one departure' unless @forwarder.departures.size == 1
      
      @departure = @forwarder.departures.last
    end
    
    subject{@departure}
    
    should_validate_uniqueness_of :city_name, :scoped_to => [:country_name, :forwarder_id]
    should_validate_uniqueness_of :country_name, :scoped_to => [:city_name, :forwarder_id]
    
    should 'have a good formatted name' do
      assert_match /Sydney, Australia/, @departure.formatted
    end
    
    context 'set to should_hide and saved' do
      setup do
        @departure["should_hide"] = "1"
        @forwarder.departure_attributes=([@departure.attributes])
        @forwarder.save!
      end
      
      should 'have been set to hidden' do
        assert @departure.hidden
      end
    end
    
    context 'set to should_destroy and saved' do
      setup do
        flunk "@departure should exist" unless @departure 
        @departure["should_destroy"] = "1"
        @forwarder.departure_attributes=([@departure.attributes])
        @forwarder.save!
        @forwarder.reload
      end
      
      should 'have been set to destactivated' do
        assert @forwarder.departures.empty?
      end
    end
  end
end
