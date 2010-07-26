class ChecklistResponse < ActiveRecord::Base
  belongs_to :checklist_option
  belongs_to :end_product
  
  validates_presence_of :answer, :on => :create
end
