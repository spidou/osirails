require File.dirname(__FILE__) + '/../sales_test'

class SurveyStepTest < ActiveSupport::TestCase
  #TODO test has_permissions
  #TODO test acts_as_step
  #TODO test has_documents
  
  should_have_many :survey_interventions, :dependent => :destroy
  should_have_many :subcontractor_requests, :dependent => :destroy
  should_have_many :subcontractors, :through => :subcontractor_requests
  #should_have_many :consultants
  
  context "A survey_step" do
    setup do
      @step = create_default_order.commercial_step.survey_step
      @attachment = File.new(File.join(Test::Unit::TestCase.fixture_path, "subcontractor_request.pdf"))
      
      flunk "employees table should have at least 2 records" unless Employee.count >= 2
      flunk "order end_products should be empty" unless @step.order.end_products.empty?
      flunk "survey_interventions should be empty" unless @step.survey_interventions.empty?
    end
    
    teardown do
      @step = nil
    end
    
    ### TEST END_PRODUCTS_ATTRIBUTES= AND SAVE END_PRODUCT
    [1, 2, 5, 10].each do |x|
      should "build #{x} new end_product(s) for its associated order" do
        x.times do
          build_default_end_product_for(@step)
        end
        
        assert_equal x, @step.order.end_products.size
      end
    end
    
    [1, 2, 5, 10].each do |x|
      should "save #{x} builded end_product(s) for its associated order" do
        x.times do
          build_default_end_product_for(@step)
        end
        @step.save!
        
        @step = SurveyStep.find(@step.id)
        assert_equal x, @step.order.end_products.count
        @step.order.end_products.each do |end_product|
          assert !end_product.new_record?
        end
      end
    end
    
    should "update existing end_product for its associated order" do
      end_product = create_default_end_product_for(@step)
      
      new_attributes = { :id          => end_product.id,
                         :name        => end_product.name + " new string",
                         :description => end_product.description + " new string",
                         :dimensions  => end_product.dimensions + " new string",
                         :quantity    => end_product.quantity + 1 }
      
      @step.end_product_attributes=( [new_attributes] )
      
      updated_end_product = @step.order.end_products.detect{ |p| p.id == end_product.id }
      new_attributes.each do |key, value|
        assert_equal value, updated_end_product.send(key)
      end
    end
    
    should "save updated end_product for its associated order" do
      end_product = create_default_end_product_for(@step)
      
      new_attributes = { :id          => end_product.id,
                         :name        => end_product.name + " new string",
                         :description => end_product.description + " new string",
                         :dimensions  => end_product.dimensions + " new string",
                         :quantity    => end_product.quantity + 1 }
      
      @step.end_product_attributes=( [new_attributes] )
      @step.save!
      
      updated_end_product = EndProduct.find(end_product.id)
      new_attributes.each do |key, value|
        assert_equal value, updated_end_product.send(key)
      end
    end
    
    should "destroy existing end_product for its associated order if should_destroy is set at '1'" do
      end_product = create_default_end_product_for(@step)
      
      new_attributes = { :id => end_product.id, :should_destroy => 1 }
      @step.end_product_attributes=( [new_attributes] )
      
      assert @step.order.end_products.detect{ |p| p.id == end_product.id }.should_destroy?
      @step.save!
      
      assert_nil SurveyStep.find(@step.id).order.end_products.detect{ |p| p.id == end_product.id }
    end
    ### END
    
    
    ### TEST SURVEY_INTERVENTIONS_ATTRIBUTES= AND SAVE_SURVEY_INTERVENTIONS
    should "NOT build new survey_intervention if should_create is not set at '1'" do
      survey_intervention_attributes = { :internal_actor_id => Employee.first.id,
                                         :start_date        => Time.now,
                                         :duration_hours    => 1,
                                         :duration_minutes  => 30,
                                         :comment           => "Comment" }
      @step.survey_intervention_attributes=( [survey_intervention_attributes] )
      
      assert_equal 0, @step.survey_interventions.size
    end
    
    [1, 2, 5, 10].each do |x|
      should "build #{x} new survey_intervention(s)" do
        x.times do
          build_default_survey_intervention_for(@step)
        end
        
        assert_equal x, @step.survey_interventions.size
      end
    end
    
    [1, 2, 5, 10].each do |x|
      should "save #{x} builded survey_intervention(s)" do
        x.times do
          build_default_survey_intervention_for(@step)
        end
        @step.save!
        
        @step = SurveyStep.find(@step.id)
        assert_equal x, @step.survey_interventions.count
        @step.survey_interventions.each do |intervention|
          assert !intervention.new_record?
        end
      end
    end
    
    should "update existing survey_intervention" do
      intervention = create_default_survey_intervention_for(@step)
      
      new_attributes = { :id                => intervention.id,
                         :internal_actor_id => Employee.last.id,
                         :start_date        => intervention.start_date + 1.day,
                         :duration_hours    => intervention.duration_hours + 1,
                         :duration_minutes  => intervention.duration_minutes + 1,
                         :comment           => intervention.comment + "new string" }
      @step.survey_intervention_attributes=( [new_attributes] )
      
      updated_intervention = @step.survey_interventions.detect{ |i| i.id == intervention.id }
      
      new_attributes.each do |key, value|
        assert_equal value, updated_intervention.send(key)
      end
    end
    
    should "save updated survey_intervention if should_update is set at '1'" do
      intervention = create_default_survey_intervention_for(@step)
      
      new_attributes = { :id                => intervention.id,
                         :internal_actor_id => Employee.last.id,
                         :start_date        => intervention.start_date + 1.day,
                         :duration_hours    => intervention.duration_hours + 1,
                         :duration_minutes  => intervention.duration_minutes + 1,
                         :comment           => intervention.comment + "new string",
                         :should_update     => 1 }
      
      @step.survey_intervention_attributes=( [new_attributes] )
      @step.save!
      
      updated_intervention = SurveyIntervention.find(intervention.id)
      new_attributes.delete(:id)
      new_attributes.delete(:should_update)
      
      new_attributes.each do |key, value|
        message = "#{key} doesn't match"
        if key == :start_date
          assert_equal value.to_s(:db), updated_intervention.send(key).to_s(:db), message
        else
          assert_equal value, updated_intervention.send(key), message
        end
      end
    end
    
    should "NOT save updated survey_intervention if should_update is NOT set at '1'" do
      intervention = create_default_survey_intervention_for(@step)
      
      new_attributes = { :id                => intervention.id,
                         :internal_actor_id => Employee.last.id,
                         :start_date        => intervention.start_date + 1.day,
                         :duration_hours    => intervention.duration_hours + 1,
                         :duration_minutes  => intervention.duration_minutes + 1,
                         :comment           => intervention.comment + "new string" }
      
      @step.survey_intervention_attributes=( [new_attributes] )
      @step.save!
      
      not_updated_intervention = SurveyIntervention.find(intervention.id)
      new_attributes.delete(:id)
      
      new_attributes.each do |key, value|
        assert_not_equal value, not_updated_intervention.send(key)
      end
    end
    
    should "destroy existing survey_intervention if should_destroy is set at '1'" do
      intervention = create_default_survey_intervention_for(@step)
      
      new_attributes = { :id => intervention.id, :should_destroy => 1 }
      @step.survey_intervention_attributes=( [new_attributes] )
      
      assert @step.survey_interventions.detect{ |i| i.id == intervention.id }.should_destroy?
      @step.save!
      
      assert_nil SurveyStep.find(@step.id).survey_interventions.detect{ |i| i.id == intervention.id }
    end
    ### END
    
    
    ### TEST SUBCONTRACTOR_REQUESTS= AND SAVE_SUBCONTRACTOR_REQUESTS
    [1, 2, 5, 10].each do |x|
      should "build #{x} new subcontractor_request(s)" do
        x.times do
          build_default_subcontractor_request_for(@step)
        end
        
        assert_equal x, @step.subcontractor_requests.size
      end
    end
    
    [1, 2, 5, 10].each do |x|
      should "save #{x} builded subcontractor_request(s)" do
        x.times do
          subcontractor_request = build_default_subcontractor_request_for(@step)
          subcontractor_request.attachment = @attachment
        end
        @step.save!
        
        @step = SurveyStep.find(@step.id)
        assert_equal x, @step.subcontractor_requests.count
        @step.subcontractor_requests.each do |subcontractor_request|
          assert !subcontractor_request.new_record?
        end
      end
    end
    
    should "update existing subcontractor_request" do
      subcontractor_request = create_default_subcontractor_request_for(@step)
      
      new_attributes = { :id                => subcontractor_request.id,
                         :job_needed        => subcontractor_request.job_needed + "new string",
                         :price             => subcontractor_request.price + 100 }
      
      @step.subcontractor_request_attributes=( [new_attributes] )
      
      updated_subcontractor_request = @step.subcontractor_requests.detect{ |s| s.id == subcontractor_request.id }
      new_attributes.each do |key, value|
        assert_equal value, updated_subcontractor_request.send(key)
      end
    end
    
    should "save updated subcontractor_request if should_update is set at '1'" do
      subcontractor_request = create_default_subcontractor_request_for(@step)
      
      new_attributes = { :id                => subcontractor_request.id,
                         :job_needed        => subcontractor_request.job_needed + "new string",
                         :price             => subcontractor_request.price + 100,
                         :should_update     => 1 }
      
      @step.subcontractor_request_attributes=( [new_attributes] )
      @step.subcontractor_requests.detect{ |s| s.id == subcontractor_request.id }.attachment = @attachment
      @step.save!
      
      updated_subcontractor_request = SubcontractorRequest.find(subcontractor_request.id)
      new_attributes.delete(:id)
      new_attributes.delete(:should_update)
      
      new_attributes.each do |key, value|
        assert_equal value, updated_subcontractor_request.send(key)
      end
    end
    
    should "NOT save updated subcontractor_request if should_update is NOT set at '1'" do
      subcontractor_request = create_default_subcontractor_request_for(@step)
      
      new_attributes = { :id                => subcontractor_request.id,
                         :job_needed        => subcontractor_request.job_needed + "new string",
                         :price             => subcontractor_request.price + 100 }
      
      @step.subcontractor_request_attributes=( [new_attributes] )
      @step.subcontractor_requests.detect{ |s| s.id == subcontractor_request.id }.attachment = @attachment
      @step.save!
      
      not_updated_subcontractor_request = SubcontractorRequest.find(subcontractor_request.id)
      new_attributes.delete(:id)
      
      new_attributes.each do |key, value|
        assert_not_equal value, not_updated_subcontractor_request.send(key)
      end
    end
    
    should "destroy existing subcontractor_request if should_destroy is set at '1'" do
      subcontractor_request = create_default_subcontractor_request_for(@step)
      
      new_attributes = { :id => subcontractor_request.id, :should_destroy => 1 }
      @step.subcontractor_request_attributes=( [new_attributes] )
      
      assert @step.subcontractor_requests.detect{ |p| p.id == subcontractor_request.id }.should_destroy?
      @step.save!
      
      assert_nil SurveyStep.find(@step.id).subcontractor_requests.detect{ |p| p.id == subcontractor_request.id }
    end
    ### END
  end
  
  private
    def build_default_end_product_for(step)
      end_product_attributes = { :product_reference_id => ProductReference.first.id,
                                 :name                 => "Name",
                                 :description          => "Description",
                                 :dimensions           => "Dimensions",
                                 :quantity             => 1 }
      step.end_product_attributes=( [end_product_attributes] )
      
      end_product_attributes.each do |key, value|
        flunk "<#{value}> expected but was \n<#{step.order.end_products.last.send(key)}>\nThese two values should be equal" unless step.order.end_products.last.send(key) == value
      end
      return step.order.end_products.last
    end
    
    def create_default_end_product_for(step)
      build_default_end_product_for(step)
      step.save!
      flunk "order should have 1 end_product" unless step.order.end_products.count == 1
      return step.order.end_products.first
    end
    
    def build_default_survey_intervention_for(step)
      survey_intervention_attributes = { :internal_actor_id => Employee.first.id,
                                         :start_date        => Time.now,
                                         :duration_hours    => 1,
                                         :duration_minutes  => 30,
                                         :comment           => "Comment",
                                         :should_create     => 1 }
      step.survey_intervention_attributes=( [survey_intervention_attributes] )
      
      survey_intervention_attributes.each do |key, value|
        flunk "<#{value}> expected but was \n<#{step.survey_interventions.last.send(key)}>\nThese two values should be equal" unless step.survey_interventions.last.send(key) == value
      end
      return step.survey_interventions.last
    end
    
    def create_default_survey_intervention_for(step)
      build_default_survey_intervention_for(step)
      step.save!
      flunk "order should have 1 survey_intervention" unless step.survey_interventions.count == 1
      return step.survey_interventions.first
    end
    
    def build_default_subcontractor_request_for(step)
      subcontractor_request_attributes = { :subcontractor_id  => Subcontractor.first.id,
                                           :job_needed        => "job needed",
                                           :price             => 100 }
      step.subcontractor_request_attributes=( [subcontractor_request_attributes] )
      
      subcontractor_request_attributes.each do |key, value|
        flunk "<#{value}> expected but was \n<#{step.subcontractor_requests.last.send(key)}>\nThese two values should be equal" unless step.subcontractor_requests.last.send(key) == value
      end
      return step.subcontractor_requests.last
    end
    
    def create_default_subcontractor_request_for(step)
      subcontractor_request = build_default_subcontractor_request_for(step)
      subcontractor_request.attachment = @attachment
      step.save!
      flunk "order should have 1 subcontractor_request" unless step.subcontractor_requests.count == 1
      return step.subcontractor_requests.first
    end
end
