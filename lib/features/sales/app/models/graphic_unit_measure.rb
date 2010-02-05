class GraphicUnitMeasure < ActiveRecord::Base
  # Relationships
  has_many :graphic_items

  # Validations
  validates_uniqueness_of :name, :symbol
  validates_presence_of :name, :symbol
end
