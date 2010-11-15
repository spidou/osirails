class SurveyIntervention < ActiveRecord::Base
  has_permissions :as_business_object
  has_documents   :plan, :mockup
  has_contact     :survey_intervention_contact, :accept_from => :order_and_customer_contacts
  
  belongs_to :survey_step
  belongs_to :internal_actor, :class_name => "Employee"
  
  validates_presence_of :start_date, :internal_actor_id
  validates_presence_of :internal_actor, :if => :internal_actor_id
  
  attr_accessor :should_destroy, :should_update, :should_create
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def should_update?
    should_update.to_i == 1
  end
  
  def should_create?
    should_create.to_i == 1
  end
  
  def duration_humanized
    if duration_hours.blank? and duration_minutes.blank?
      render = "Durée non renseignée"
    else
      render = duration_hours.blank? ? '' : ( duration_hours.to_s + ' h' )
      render << ' ' unless render.empty?
      render << duration_minutes.to_s.rjust(2, '0') + ' min' unless duration_minutes.blank?
    end
    return render
  end
  
  def order_and_customer_contacts
    survey_step_id ? SurveyStep.find(survey_step_id).order.all_contacts_and_customer_contacts : []
  end
end
