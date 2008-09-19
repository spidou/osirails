class SalesProcessesSteps < ActiveRecord::Base
  # Relationships
  belongs_to :sales_process
  belongs_to :step
end