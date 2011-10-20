class SendQuoteMethod < ActiveRecord::Base  
  journalize :identifier_method => :name
  
  has_search_index :only_attributes => [:id, :name],
                   :identifier      => :name
end
