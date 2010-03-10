class ChecklistResponse < ActiveRecord::Base
  belongs_to :checklist_option
  belongs_to :product
  
  validates_presence_of :answer, :on => :create
end
