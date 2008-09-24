class Salary < ActiveRecord::Base
  belongs_to :job_contract
  validates_format_of :salary , :with => /^[1-9]+(\d)*((\x2E)(\d)*)+$/ , :message => "le montant du salaire doit être un nombre"
end
