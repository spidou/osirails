class OrdersSteps < ActiveRecord::Base
  # Relationships
  belongs_to :order
  belongs_to :step
  has_many :checklist_responses
  has_many :missing_elements
  has_many :remarks, :as => :has_remark
  
  def name
    step.name
  end
  
  def title
    step.title
  end
end