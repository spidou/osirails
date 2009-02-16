class Salary < ActiveRecord::Base
  belongs_to :job_contract
  validates_format_of :salary , :with => /^[1-9]+(\d)*((\x2E)(\d)*)+$/ , :message => "le montant du salaire doit être un nombre"

  # method that return the net salary
  def net_salary
    return self.salary -= self.salary * 0.20 
  end

  # method to get the brut salary
  def brut_salary
    return self.salary
  end

end
