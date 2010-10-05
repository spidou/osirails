require File.dirname(__FILE__) + '/../thirds_test'

class ForwarderTest < ActiveSupport::TestCase
  #TODO has_permissions :as_business_object
  
  should_have_many :forwarder_departures
  should_have_many :departures
  should_have_many :forwarder_conveyances
  should_have_many :conveyances
  
  should_have_one :iban
  
  should_validate_uniqueness_of :name
  
  context "A forwarder" do
    setup do
      @siret_number_owner = Forwarder.new
    end
    
    subject{ @siret_number_owner }
    
    include SiretNumberTest
  end
  
  context "A new forwarder with a name defined" do
    setup do
      @supplier = Forwarder.new(:name => "Forwarder name")
    end
    
    subject{ @supplier }
    
    include SupplierBaseTest
  end
  
  context "A saved forwarder" do
    setup do
      @forwarder = create_forwarder
    end
    
    context 'on which we add a forwarder_conveyance' do
      setup do
        @user = create_user
        
        @conveyance = Conveyance.new(:name => "Avion", :creator_id => @user.id)
        @conveyance.save!
        flunk 'Should NOT have forwarder_conveyance yet' unless @forwarder.forwarder_conveyances.empty?
        @forwarder.forwarder_conveyances.build(:forwarder_id => @forwarder.id, :conveyance_id => @conveyance.id )
        @forwarder.valid?
      end
      
      should 'have a forwarder_conveyance associated' do
        assert_equal 1, @forwarder.forwarder_conveyances.size
      end
      
#      should 'have built a forwarder_conveyance' do
#        assert_equal 1, @forwarder.forwarder_conveyances.size
#      end
      
      context 'and then is saved again' do
        setup do
          flunk 'The forwarder_conveyance should NOT have an id yet' unless @forwarder.forwarder_conveyances.last.id.nil?
          @forwarder.save!
        end
        
        should 'have saved the forwarder_conveyance too' do
          assert_not_nil @forwarder.forwarder_conveyances.last.id
        end
        
        should 'have a forwarder_conveyance with an id' do
          assert_not_nil @forwarder.forwarder_conveyances.last.id
        end
      end
    end
    
    context 'on which we add a departure' do
      setup do
        @user = create_user
        flunk 'Should NOT have forwarder_departure yet' unless @forwarder.forwarder_departures.empty?
        @departure = Departure.new(:city_name => "Paris", :country_name => "France", :creator_id => @user.id)
        @departure.save!
        @forwarder.forwarder_departures.build(:forwarder_id => @forwarder.id, :departure_id => @departure.id)
        @forwarder.valid?
      end
      
      should 'have a forwarder_departure associated' do
        assert @forwarder.forwarder_departures.any?
      end
      
      context 'and then is saved again' do
        setup do
          flunk 'Departure should NOT have an id yet' unless @forwarder.forwarder_departures.last.id.nil?
          @forwarder.save!
        end
        
        should 'have created a forwarder_departure' do
          assert_not_nil @forwarder.forwarder_departures.last.id
        end
      end
    end
  end
  
  context 'A forwarder with forwarder_conveyances' do
    setup do
      @user = create_user
      @conveyance1 = Conveyance.new(:name => "Car", :creator_id => @user.id)
      @conveyance1.save!
      @conveyance2 = Conveyance.new(:name => "Plane", :creator_id => @user.id)
      @conveyance2.save!
      @conveyance3 = Conveyance.new(:name => "Boat", :creator_id => @user.id)
      @conveyance3.save!
      @forwarder = create_forwarder
      flunk 'The forwarder should not have forwarder_conveyances yet' unless @forwarder.forwarder_conveyances.empty?
      @forwarder.forwarder_conveyances.build(:conveyance_id => @conveyance1.id )
      @forwarder.forwarder_conveyances.build(:conveyance_id => @conveyance2.id )
      @forwarder.forwarder_conveyances.build(:conveyance_id => @conveyance3.id )
      @forwarder.save!
    end
    
    should 'have 3 conveyances associated' do
      assert_equal 3, @forwarder.forwarder_conveyances.size
    end
    
    context 'which we remove a forwarder_conveyance' do
      setup do
        conveyances_attributes = [{:forwarder_conveyance_ids => @conveyance1.id, :forwarder_conveyance_ids => @conveyance2.id }]
        @forwarder.forwarder_conveyances_attributes=(conveyances_attributes)
        @forwarder.save!
        @forwarder.reload
      end
      
      should 'NOT have the conveyance3 associated anymore' do
        assert_nil @forwarder.forwarder_conveyances.detect{ |forwarder_conveyance| forwarder_conveyance.conveyance_id == @conveyance3.id }
      end
    end
  end
  
  context 'A forwarder with forwarder_departures' do
    setup do
      @user = create_user
      @departure1 = Departure.new(:city_name => "New York", :country_name => "United States Of America", :creator_id => @user.id)
      @departure1.save!
      @departure2 = Departure.new(:city_name => "San Diego", :country_name => "United States Of America", :creator_id => @user.id)
      @departure2.save!
      @departure3 = Departure.new(:city_name => "Paris", :country_name => "France", :creator_id => @user.id)
      @departure3.save!
      @forwarder = create_forwarder
      flunk 'The forwarder should not have forwarder_departures yet' unless @forwarder.forwarder_departures.empty?
      @forwarder.forwarder_departures.build(:departure_id => @departure1.id )
      @forwarder.forwarder_departures.build(:departure_id => @departure2.id )
      @forwarder.forwarder_departures.build(:departure_id => @departure3.id )
      @forwarder.save!
    end
    
    should 'have 3 departures associated' do
      assert_equal 3, @forwarder.forwarder_departures.size
    end
    
    context 'which we remove a forwarder_departure' do
      setup do
        departures_attributes = [{:forwarder_departure_ids => @departure1.id, :forwarder_departure_ids => @departure2.id }]
        @forwarder.forwarder_departures_attributes=(departures_attributes)
        @forwarder.save!
        @forwarder.reload
      end
      
      should 'NOT have the departure3 associated anymore' do
        assert_nil @forwarder.forwarder_departures.detect{ |forwarder_departure| forwarder_departure.departure_id == @departure3.id }
      end
    end
  end

## when forwarder will have establishment
#  context "A new forwarder" do
#    setup do
#      @forwarder = Forwarder.new(:name => "Forwarder name")
#      @customer = @forwarder
#    end
#    
#    subject{@customer}
#    include CustomerBaseTest
#  end

end
