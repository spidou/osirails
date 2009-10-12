class ChecklistResponse < ActiveRecord::Base
  #belongs_to :checklist
  belongs_to :checklist_option
  belongs_to :order
end
