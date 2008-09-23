class CommercialOrder < ActiveRecord::Base
  belongs_to :order
  
  belongs_to :step
  has_many :checklist_responses
  has_many :missing_elements
  has_many :remarks, :as => :has_remark
  
  ## Plugins
  acts_as_file
  
  def name
    step.name
  end
  
  def title
    step.title
  end
end