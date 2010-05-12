require 'test/test_helper'

class SurveyInterventionTest < ActiveSupport::TestCase
  
  #TODO test has_permissions
  #TODO test has_documents
  #TODO test has_contact
  
  should_belong_to :survey_step, :internal_actor
  
  should_validate_presence_of :start_date
  should_validate_presence_of :internal_actor, :with_foreign_key => :default
  
  context "A survey_intervention" do
    setup do
      @intervention = SurveyIntervention.new
    end
    
    teardown do
      @intervention = nil
    end
    
    context "with neither duration_hours not duration_minutes given" do
      should "have a specific duration_humanized value" do
        assert "Durée non renseignée", @intervention.duration_humanized
      end
    end
    
    context "with a duration_hours and no duration_minutes" do
      setup do
        @intervention.duration_hours = 1
      end
      
      teardown do
        @intervention.duration_hours = nil
      end
      
      should "have a duration_humanized value" do
        assert "1 h", @intervention.duration_humanized
      end
    end
    
    context "with a duration_minutes and no duration_hours" do
      setup do
        @intervention.duration_minutes = 30
      end
      
      teardown do
        @intervention.duration_minutes = nil
      end
      
      should "have a duration_humanized value" do
        assert "30 min", @intervention.duration_humanized
      end
    end
    
    context "with a duration_hours and a duration_minutes" do
      setup do
        @intervention.duration_hours = 1
        @intervention.duration_minutes = 30
      end
      
      teardown do
        @intervention.duration_hours = @intervention.duration_minutes = nil
      end
      
      should "have a duration_humanized value" do
        assert "1 h 30 min", @intervention.duration_humanized
      end
    end
  end
  
  context "Thanks to 'has_contact', a survey_intervention" do
    setup do
      @contact_owner = create_default_survey_intervention
      @contact_keys = [ :survey_intervention_contact ]
    end
    
    subject { @contact_owner }
          
    should_belong_to :survey_intervention_contact
    
    include HasContactTest
  end
  
  private
  
    def create_default_survey_intervention
      s = SurveyIntervention.new( :internal_actor_id  => employees(:john_doe).id,
                                  :start_date         => Date.today)
      s.save!
      return s
    end
end
