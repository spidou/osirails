class InvoiceType < ActiveRecord::Base
  validates_presence_of :name
  
  validates_uniqueness_of :name
  
  validates_inclusion_of :factorisable, :in => [true, false]
end
