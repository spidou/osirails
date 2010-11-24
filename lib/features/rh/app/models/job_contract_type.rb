class JobContractType < ActiveRecord::Base
  validates_presence_of :name
  validates_inclusion_of :limited, :in => [true, false]
  
  journalize :identifier_method => :name
  
  has_search_index :only_attributes => [:limited, :name, :id],
                   :identifier => :name
end
