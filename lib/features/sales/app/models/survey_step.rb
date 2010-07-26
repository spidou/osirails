class SurveyStep < ActiveRecord::Base
  has_permissions :as_business_object
  acts_as_step
  has_documents :plan, :mockup, :photo
  
  has_many :survey_interventions, :dependent => :destroy
  has_many :subcontractor_requests, :dependent => :destroy
  has_many :subcontractors, :through => :subcontractor_requests, :source => :subcontractor
  
  validates_associated :order, :unless => :new_record?
  validates_associated :survey_interventions, :subcontractor_requests
  
  after_save :save_end_products, :save_survey_interventions, :save_subcontractor_requests
  
  def end_product_attributes=(end_product_attributes)
    end_product_attributes.each do |attributes|
      if attributes[:id].blank?
        order.end_products.build(attributes)
      else
        end_product = order.end_products.detect { |t| t.id == attributes[:id].to_i }
        end_product.attributes = attributes
      end
    end
  end
  
  def save_end_products
    order.end_products.each do |p|
      if p.should_destroy?
        p.destroy
      else
        p.save(false)
      end
    end
  end
  
  def survey_intervention_attributes=(survey_intervention_attributes)
    survey_intervention_attributes.each do |attributes|
      if attributes[:id].blank?
        survey_interventions.build(attributes) if attributes[:should_create].to_i == 1
      else
        survey_intervention = survey_interventions.detect { |t| t.id == attributes[:id].to_i }
        survey_intervention.attributes = attributes
      end
    end
  end
  
  def save_survey_interventions
    survey_interventions.each do |s|
      if s.should_destroy?
        s.destroy
      elsif (s.should_create? and s.new_record?) or s.should_update?
        s.save(false)
      end
    end
  end
  
  def subcontractor_request_attributes=(subcontractor_request_attributes)
    subcontractor_request_attributes.each do |attributes|
      if attributes[:id].blank?
        subcontractor_requests.build(attributes)
      else
        subcontractor_request = subcontractor_requests.detect { |t| t.id == attributes[:id].to_i }
        subcontractor_request.attributes = attributes
      end
    end
  end
  
  def save_subcontractor_requests
    subcontractor_requests.each do |s|
      if s.should_destroy?
        s.destroy
      elsif s.should_update?
        s.save(false)
      end
    end
  end
  
end
