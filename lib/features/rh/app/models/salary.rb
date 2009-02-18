class Salary < ActiveRecord::Base
  belongs_to :job_contract
  validates_format_of :gross_amount  , :with => /^[1-9]+(\d)*((\x2E)(\d)*)+$/ , :message => "le montant du salaire doit être un nombre"
  
  RATIO_FOR_NET_AMOUNT = 0.3
  
  #Accessors
  cattr_accessor :form_labels

  @@form_labels = Hash.new
  @@form_labels[:gross_amount] = "Salaire Brut :"
  
  # method that return the net amount of the salary
  def net_amount
    self.gross_amount -= self.gross_amount * RATIO_FOR_NET_AMOUNT
  end
end
