class Step < ActiveRecord::Base
  # Relationships
  has_and_belongs_to_many :sales_processes
  has_and_belongs_to_many :orders
  has_many :checklists
end
