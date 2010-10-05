require File.dirname(__FILE__) + '/../thirds_test'

class DepartureTest < ActiveSupport::TestCase
  should_have_many :forwarder_departures
  should_have_many :forwarders
  
  should_validate_presence_of :city_name, :country_name
  should_validate_presence_of :creator, :with_foreign_key => :default
  should_validate_uniqueness_of :city_name, :country_name
  
  context 'A new departure associated to a forwarder' do
    setup do
      @user = create_user
      @forwarder = create_forwarder
      @departure = Departure.new(:city_name => "City Name", :country_name => "Country Name", :creator_id => @user.id)
      flunk 'Should NOT have forwarder_departures yet' unless @departure.forwarder_departures.size == 0
      
      @departure.save!
      
      @departure.forwarder_departures.build(:forwarder_id => @forwarder.id)
      flunk 'Should have one forwarder_departures' unless @departure.forwarder_departures.size == 1
    end
    
    should 'be saved successfully' do
      @departure.save!
      assert_not_nil @departure.forwarder_departures.last.id
    end
    
    context 'then saved' do
      setup do
        @departure.save!
      end
      
      should 'NOT be able to be destroyed' do
        assert !@departure.can_be_destroyed?
      end
      
      should 'NOT destroy successfully' do
        assert !@departure.destroy
      end
      
      context 'and then desassociated to the forwarder' do
        setup do
          @departure.forwarder_departures.last.destroy
          @departure.reload
          flunk 'Should NOT be associated to forwarder anymore' unless @departure.forwarder_departures.size == 0
        end
        
        should 'should be able to be destroyed' do
          assert @departure.can_be_destroyed?
        end
        
        should 'be destroyed successfully' do
          assert @departure.destroy
        end
      end
    end
  end
end
