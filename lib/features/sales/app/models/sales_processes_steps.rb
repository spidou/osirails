class SalesProcessesSteps < ActiveRecord::Base
  belongs_to :sales_process
  belongs_to :step
end
