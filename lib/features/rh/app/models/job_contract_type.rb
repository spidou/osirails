class JobContractType < ActiveRecord::Base
  validates_presence_of :name
  validates_inclusion_of :limited, :in => [true, false]
end
