class UnitMeasure < ActiveRecord::Base
  # Validates
  validates_presence_of :name, :symbol
end
