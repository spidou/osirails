class StepInvoicing < ActiveRecord::Base
  acts_as_step :children => []
end
