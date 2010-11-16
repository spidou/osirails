class JobContractType < ActiveRecord::Base
  journalize :identifier_method => :name

  validates_presence_of :name
  validates_inclusion_of :limited, :in => [true, false]
  
  has_search_index :only_attributes => [:limited, :name, :id],
                   :identifier => :name
end
