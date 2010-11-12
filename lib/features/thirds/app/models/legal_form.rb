class LegalForm < ActiveRecord::Base
  belongs_to :third_type
  
  validates_presence_of :name
  
  has_search_index :only_attributes => [ :id, :name ],
                   :identifier      => :name
end
