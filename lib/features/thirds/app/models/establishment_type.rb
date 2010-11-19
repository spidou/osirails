class EstablishmentType < ActiveRecord::Base
  validates_presence_of :name
  
  journalize :identifier_method => :name
  
  has_search_index :only_attributes => [ :id, :name ],
                   :identifier      => :name
end
