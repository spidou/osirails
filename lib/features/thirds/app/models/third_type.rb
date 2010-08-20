class ThirdType < ActiveRecord::Base
  has_many :legal_forms
  validates_presence_of :name
end
