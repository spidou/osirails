class ChecklistOptionsOrderType < ActiveRecord::Base
  belongs_to :checklist_option
  belongs_to :order_type
end
