class Job < ActiveRecord::Base
  has_permissions :as_business_object

  has_and_belongs_to_many :employees
  validates_uniqueness_of :name, :message => "la fonction existe déjà!"
end  
