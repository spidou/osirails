class UnitMeasure < ActiveRecord::Base
  #FIXME think to create new controller

  # Validations
  validates_presence_of :name, :symbol
end
