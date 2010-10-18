require File.dirname(__FILE__) + '/../thirds_test'

class ForwarderTest < ActiveSupport::TestCase
  #TODO has_permissions :as_business_object
  
  should_have_many :departures
  should_have_many :forwarder_conveyances
  should_have_many :conveyances
  
  should_belong_to :creator
  
  context "A forwarder" do
    setup do
      @siret_number_owner = Forwarder.new
    end
    
    subject{ @siret_number_owner }
    
    include SiretNumberTest
  end
  
  context "A forwarder" do
    setup do
      @forwarder = create_forwarder
    end
    
    subject{@forwarder}
    
    should_validate_uniqueness_of :name, :scoped_to => :type
  end
  
  context "A saved forwarder" do
    setup do
      @forwarder = create_forwarder
    end
    
    context 'on which we add a forwarder_conveyance and then we save again' do
      setup do
        @conveyance = Conveyance.new(:name => "Avion")
        @conveyance.save!
        flunk '@forwarder should NOT have a forwarder_conveyance' unless @forwarder.forwarder_conveyances.empty?
        
        @forwarder.forwarder_conveyances.build(:conveyance_id => @conveyance.id )
        flunk '@forwarder should have a forwarder_conveyance' unless @forwarder.forwarder_conveyances.size == 1
        flunk 'forwarder_conveyance should not have an id yet' unless @forwarder.forwarder_conveyances.last.id.nil?
        @forwarder.save!
      end
      
      should 'have saved the forwarder_conveyance too' do
        assert_not_nil @forwarder.forwarder_conveyances.last.id
      end
      
      should 'have a forwarder_conveyance with an id' do
        assert_not_nil @forwarder.forwarder_conveyances.last.id
      end
    end
    
    context 'on which we add a departure' do
      setup do
        flunk 'Should NOT have forwarder_departure yet' unless @forwarder.departures.empty?
        @forwarder.departures.build(:city_name => "Paris", :country_name => "France")
        @forwarder.save!
      end
      
      should 'have created a forwarder_departure' do
        assert_not_nil @forwarder.departures.last.id
      end
    end
  end
  
  context 'A forwarder with forwarder_conveyances' do
    setup do
      @conveyance1 = Conveyance.create! :name => "Car"
      @conveyance2 = Conveyance.create! :name => "Plane"
      @conveyance3 = Conveyance.create! :name => "Boat"
      @forwarder = create_forwarder
      flunk 'The forwarder should not have forwarder_conveyances yet' unless @forwarder.forwarder_conveyances.empty?
      @forwarder.forwarder_conveyances.build(:conveyance_id => @conveyance1.id)
      @forwarder.forwarder_conveyances.build(:conveyance_id => @conveyance2.id)
      @forwarder.forwarder_conveyances.build(:conveyance_id => @conveyance3.id)
      @forwarder.save!
    end
    
    should 'have 3 conveyances associated' do
      assert_equal 3, @forwarder.forwarder_conveyances.size
    end
    
    context 'on which we remove a forwarder_conveyance' do
      setup do
        @forwarder.forwarder_conveyances_attributes=([{:forwarder_conveyance_ids => @conveyance1.id, :forwarder_conveyance_ids => @conveyance2.id }])
        @forwarder.save!
        @forwarder.reload
      end
      
      should 'NOT have the conveyance3 associated anymore' do
        assert_nil @forwarder.forwarder_conveyances.detect{ |forwarder_conveyance| forwarder_conveyance.conveyance_id == @conveyance3.id }
      end
    end
  end
end
