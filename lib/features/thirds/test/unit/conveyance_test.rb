require File.dirname(__FILE__) + '/../thirds_test'

class ConveyanceTest < ActiveSupport::TestCase
  should_have_many :forwarder_conveyances
  should_have_many :forwarders
  
  should_validate_presence_of :name
  should_validate_uniqueness_of :name
  
  context 'A new conveyance associated to a forwarder' do
    setup do
      @user = create_user
      @forwarder = create_forwarder
      @conveyance = Conveyance.new(:name => "Conveyance Name", :creator_id => @user.id)
      flunk 'Should NOT have forwarder_conveyances yet' unless @conveyance.forwarder_conveyances.size == 0
      
      @conveyance.forwarder_conveyances.build(:forwarder_id => @forwarder.id)
      flunk 'Should have one forwarder_conveyances' unless @conveyance.forwarder_conveyances.size == 1
      
      @conveyance.save!
    end
    
    should 'be saved successfully' do
      assert_not_nil @conveyance.forwarder_conveyances.last.id
    end
    
    context 'then saved' do
      setup do
        @conveyance.save!
      end
      
      should 'NOT be able to be destroyed' do
        assert !@conveyance.can_be_destroyed?
      end
      
      should 'NOT destroy successfully' do
        assert !@conveyance.destroy
      end
      
      context 'and then desassociated to the forwarder' do
        setup do
          @conveyance.forwarder_conveyances.last.destroy
          @conveyance.reload
          flunk 'Should NOT be associated to forwarder anymore' unless @conveyance.forwarder_conveyances.size == 0
        end
        
        should 'should be able to be destroyed' do
          assert @conveyance.can_be_destroyed?
        end
        
        should 'be destroyed successfully' do
          assert @conveyance.destroy
        end
      end
    end
  end
end
