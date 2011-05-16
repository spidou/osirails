require File.dirname(__FILE__) + '/../sales_test'

class SurveyStepTest < ActiveSupport::TestCase
  #TODO test has_permissions
  #TODO test acts_as_step
  #TODO test has_documents
  
  should_have_many :survey_interventions, :dependent => :destroy
  should_have_many :subcontractor_requests, :dependent => :destroy
  should_have_many :subcontractors, :through => :subcontractor_requests
  #should_have_many :consultants
  
  # test 'end_product_attributes=' and 'save_end_products' (when creating new records)
  context "Given an order with 0 end_products, a survey_step" do
    setup do
      @order = create_default_order
      @step = @order.commercial_step.survey_step
      
      flunk "@order should have 0 end_products" unless @step.order.end_products.empty?
    end
    
    context "which call end_product_attributes= with 2 elements" do
      setup do
        attributes = [{ :product_reference_id => ProductReference.first.id,
                        :name                 => "Name",
                        :description          => "Description",
                        :quantity             => 1 },
                      { :product_reference_id => ProductReference.last.id,
                        :name                 => "Name",
                        :description          => "Description",
                        :quantity             => 1 }]
        @step.end_product_attributes=(attributes)
        
        flunk "@step should be valid" unless @step.valid?
      end
      
      should "have 2 newly built end_products on its associated order" do
        assert_equal 2, @step.order.end_products.select(&:new_record?).size
      end
      
      should "save built end_products on its associated order" do
        @step.save!
        @step.reload
        
        assert_equal 2, @step.order.end_products.count
      end
    end
  end
  
  # test 'end_product_attributes=' and 'save_end_products' (when updating existing records)
  context "Given an order with 1 end_product, a survey_step" do
    setup do
      @order = create_default_order
      @step = @order.commercial_step.survey_step
      
      @end_product = create_default_end_product(@order, :description => 'Default description')
      flunk "@order should have 1 end_product" unless @step.order.end_products(true).size == 1
    end
    
    context "which call end_product_attributes= with 1 element" do
      setup do
        @new_attributes = { :id          => @end_product.id,
                            :name        => @end_product.name + " new string",
                            :description => @end_product.description + " new string",
                            :quantity    => @end_product.quantity + 1 }
        @step.end_product_attributes=( [@new_attributes] )
        
        flunk "@step should be valid" unless @step.valid?
      end
      
      should "update existing end_product for its associated order" do
        updated_end_product = @step.order.end_products.detect{ |p| p.id == @end_product.id }
        @new_attributes.each do |key, value|
          assert_equal value, updated_end_product.send(key)
        end
      end
      
      should "save updated end_product for its associated order" do
        @step.save!
        
        updated_end_product = EndProduct.find(@end_product.id)
        @new_attributes.each do |key, value|
          assert_equal value, updated_end_product.send(key)
        end
      end
    end
    
    context "which call end_product_attributes= with 1 element - which is marked to be destroyed -" do
      setup do
        @new_attributes = { :id => @end_product.id, :should_destroy => 1 }
        @step.end_product_attributes=( [@new_attributes] )
        
        flunk "end_product should be marked to be destroyed" unless @step.order.end_products.detect{ |p| p.id == @end_product.id }.should_destroy?
        flunk "@step should be valid" unless @step.valid?
      end
      
      should "destroy existing end_product for its associated order" do
        @step.save!
        
        assert_nil SurveyStep.find(@step.id).order.end_products(true).detect{ |p| p.id == end_product.id }
        assert_nil EndProduct.find_by_id(@end_product.id)
      end
    end
  end
  
  # test 'survey_intervention_attributes=' and 'save_survey_interventions'
  context "Given an order with 0 survey_interventions, a survey_step" do
    setup do
      @order = create_default_order
      @step = @order.commercial_step.survey_step
      
      flunk "@step should have 0 survey_interventions" unless @step.survey_interventions.empty?
    end
    
    should "NOT build new survey_intervention if should_create is not set at '1'" do
      survey_intervention_attributes = { :internal_actor_id => Employee.first.id,
                                         :start_date        => Time.now,
                                         :duration_hours    => 1,
                                         :duration_minutes  => 30,
                                         :comment           => "Comment" }
      @step.survey_intervention_attributes=( [survey_intervention_attributes] )
      
      assert_equal 0, @step.survey_interventions.size
    end
    
    context "which call survey_intervention_attributes= with 1 element" do
      setup do
        build_default_survey_intervention_for(@step)
        
        flunk "@step should be valid" unless @step.valid?
      end
      
      should "build 1 survey_intervention" do
        assert_equal 1, @step.survey_interventions.select(&:new_record?).size
      end
      
      should "save the built survey_intervention" do
        @step.save!
        
        assert_equal 1, @step.survey_interventions(true).count
      end
    end
  end
  
  # test 'survey_intervention_attributes=' and 'save_survey_interventions'
  context "Given an order with 1 survey_interventions, a survey_step" do
    setup do
      @order = create_default_order
      @step = @order.commercial_step.survey_step
      
      @intervention = create_default_survey_intervention_for(@step)
      
      flunk "employees table should have at least 2 records" unless Employee.count >= 2
    end
    
    context "which call survey_intervention_attributes= with 1 element" do
      setup do
        @new_attributes = { :id                => @intervention.id,
                            :internal_actor_id => Employee.last.id,
                            :start_date        => @intervention.start_date + 1.day,
                            :duration_hours    => @intervention.duration_hours + 1,
                            :duration_minutes  => @intervention.duration_minutes + 1,
                            :comment           => @intervention.comment + "new string" }
        @step.survey_intervention_attributes=( [@new_attributes] )
        
        flunk "@step should be valid" unless @step.valid?
      end
    
      should "update existing survey_intervention" do
        updated_intervention = @step.survey_interventions.detect{ |i| i.id == @intervention.id }
        
        @new_attributes.each do |key, value|
          assert_equal value, updated_intervention.send(key)
        end
      end
    end
    
    context "which call survey_intervention_attributes= with 1 element - which is marked to be updated -" do
      setup do
        @new_attributes = { :id                => @intervention.id,
                            :internal_actor_id => Employee.last.id,
                            :start_date        => @intervention.start_date + 1.day,
                            :duration_hours    => @intervention.duration_hours + 1,
                            :duration_minutes  => @intervention.duration_minutes + 1,
                            :comment           => @intervention.comment + "new string",
                            :should_update     => 1 }
        @step.survey_intervention_attributes=( [@new_attributes] )
        
        flunk "survey_intervention should be marked to be updated" unless @step.survey_interventions.detect{ |p| p.id == @intervention.id }.should_update?
        flunk "@step should be valid" unless @step.valid?
      end
    
      should "save updated survey_intervention" do
        @step.save!
        
        updated_intervention = SurveyIntervention.find(@intervention.id)
        @new_attributes.delete(:should_update)
        
        @new_attributes.each do |key, value|
          message = "#{key} doesn't match"
          if key == :start_date
            assert_equal value.to_s(:db), updated_intervention.send(key).to_s(:db), message
          else
            assert_equal value, updated_intervention.send(key), message
          end
        end
      end
    end
    
    context "which call survey_intervention_attributes= with 1 element - which is NOT marked to be updated -" do
      setup do
        @new_attributes = { :id                => @intervention.id,
                            :internal_actor_id => Employee.last.id,
                            :start_date        => @intervention.start_date + 1.day,
                            :duration_hours    => @intervention.duration_hours + 1,
                            :duration_minutes  => @intervention.duration_minutes + 1,
                            :comment           => @intervention.comment + "new string" }
        @step.survey_intervention_attributes=( [@new_attributes] )
        
        flunk "survey_intervention should NOT be marked to be updated" if @step.survey_interventions.detect{ |p| p.id == @intervention.id }.should_update?
        flunk "@step should be valid" unless @step.valid?
      end
    
      should "NOT save updated survey_intervention" do
        @step.save!
        
        not_updated_intervention = SurveyIntervention.find(@intervention.id)
        @new_attributes.delete(:id)
        
        @new_attributes.each do |key, value|
          assert_not_equal value, not_updated_intervention.send(key)
        end
      end
    end
    
    context "which call survey_intervention_attributes= with 1 element - which is marked to be destroyed -" do
      setup do
        @new_attributes = { :id => @intervention.id, :should_destroy => 1 }
        @step.survey_intervention_attributes=( [@new_attributes] )
        
        flunk "survey_intervention should be marked to be destroyed" unless @step.survey_interventions.detect{ |p| p.id == @intervention.id }.should_destroy?
        flunk "@step should be valid" unless @step.valid?
      end
      
      should "destroy existing survey_intervention" do
        @step.save
        @step.reload
        
        assert_nil @step.survey_interventions.detect{ |i| i.id == @intervention.id }
        assert_nil SurveyIntervention.find_by_id(@intervention.id)
      end
    end
  end
  
  # test 'subcontractor_request_attributes=' and 'save_subcontractor_requests' (when creating new records)
  context "Given an order with 0 subcontractor_requests, a survey_step" do
    setup do
      @order = create_default_order
      @step = @order.commercial_step.survey_step
      
      flunk "@step should have 0 subcontractor_requests" unless @step.subcontractor_requests.empty?
    end
    
    context "which call subcontractor_request_attributes= with 1 element" do
      setup do
        @subcontractor_request = build_default_subcontractor_request_for(@step)
        @subcontractor_request.attachment = default_attachment # subcontractor_request need an attachment to be valid
        
        flunk "@step should be valid" unless @step.valid?
      end
      
      should "build 1 subcontractor_request" do
        assert_equal 1, @step.subcontractor_requests.select(&:new_record?).size
      end
      
      should "save the built subcontractor_request" do
        @step.save!
        
        assert_equal 1, @step.subcontractor_requests(true).count
      end
    end
  end
  
  # test 'subcontractor_request_attributes=' and 'save_subcontractor_requests' (when updating existing records)
  context "Given an order with 1 subcontractor_request, a survey_step" do
    setup do
      @order = create_default_order
      @step = @order.commercial_step.survey_step
      
      @subcontractor_request = create_default_subcontractor_request_for(@step)
      
      flunk "@step should have 1 subcontractor_request" unless @step.subcontractor_requests(true).size == 1
      flunk "subcontractors table should have at least 2 records" unless Subcontractor.count >= 2
    end
    
    context "which call subcontractor_request_attributes= with 1 element" do
      setup do
        @new_attributes = { :id               => @subcontractor_request.id,
                            :subcontractor_id => Subcontractor.last.id,
                            :job_needed       => @subcontractor_request.job_needed + " new string",
                            :price            => @subcontractor_request.price + 100 }
        @step.subcontractor_request_attributes=( [@new_attributes] )
        
        flunk "@step should be valid" unless @step.valid?
      end
    
      should "update existing subcontractor_request" do
        updated_intervention = @step.subcontractor_requests.detect{ |i| i.id == @subcontractor_request.id }
        
        @new_attributes.each do |key, value|
          assert_equal value, updated_intervention.send(key)
        end
      end
    end
    
    context "which call subcontractor_request_attributes= with 1 element - which is marked to be updated -" do
      setup do
        @new_attributes = { :id               => @subcontractor_request.id,
                            :subcontractor_id => Subcontractor.last.id,
                            :job_needed       => @subcontractor_request.job_needed + " new string",
                            :price            => @subcontractor_request.price + 100,
                            :should_update    => 1 }
        @step.subcontractor_request_attributes=( [@new_attributes] )
        
        flunk "subcontractor_request should be marked to be updated" unless @step.subcontractor_requests.detect{ |p| p.id == @subcontractor_request.id }.should_update?
        flunk "@step should be valid" unless @step.valid?
      end
    
      should "save updated subcontractor_request" do
        @step.save!
        
        updated_intervention = SubcontractorRequest.find(@subcontractor_request.id)
        @new_attributes.delete(:should_update)
        
        @new_attributes.each do |key, value|
          message = "#{key} doesn't match"
          if key == :start_date
            assert_equal value.to_s(:db), updated_intervention.send(key).to_s(:db), message
          else
            assert_equal value, updated_intervention.send(key), message
          end
        end
      end
    end
    
    context "which call subcontractor_request_attributes= with 1 element - which is NOT marked to be updated -" do
      setup do
        @new_attributes = { :id               => @subcontractor_request.id,
                            :subcontractor_id => Subcontractor.last.id,
                            :job_needed       => @subcontractor_request.job_needed + " new string",
                            :price            => @subcontractor_request.price + 100 }
        @step.subcontractor_request_attributes=( [@new_attributes] )
        
        flunk "subcontractor_request should NOT be marked to be updated" if @step.subcontractor_requests.detect{ |p| p.id == @subcontractor_request.id }.should_update?
        flunk "@step should be valid" unless @step.valid?
      end
    
      should "NOT save updated subcontractor_request" do
        @step.save!
        
        not_updated_intervention = SubcontractorRequest.find(@subcontractor_request.id)
        @new_attributes.delete(:id)
        
        @new_attributes.each do |key, value|
          assert_not_equal value, not_updated_intervention.send(key)
        end
      end
    end
    
    context "which call subcontractor_request_attributes= with 1 element - which is marked to be destroyed -" do
      setup do
        @new_attributes = { :id => @subcontractor_request.id, :should_destroy => 1 }
        @step.subcontractor_request_attributes=( [@new_attributes] )
        
        flunk "subcontractor_request should be marked to be destroyed" unless @step.subcontractor_requests.detect{ |p| p.id == @subcontractor_request.id }.should_destroy?
        flunk "@step should be valid" unless @step.valid?
      end
      
      should "destroy existing subcontractor_request" do
        @step.save
        @step.reload
        
        assert_nil @step.subcontractor_requests.detect{ |i| i.id == @subcontractor_request.id }
        assert_nil SubcontractorRequest.find_by_id(@subcontractor_request.id)
      end
    end
  end
  
  private
    def default_attachment
      File.new(File.join(Test::Unit::TestCase.fixture_path, "subcontractor_request.pdf"))
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
      subcontractor_request.attachment = default_attachment
      step.save!
      flunk "order should have 1 subcontractor_request" unless step.subcontractor_requests.count == 1
      return step.subcontractor_requests.first
    end
end
