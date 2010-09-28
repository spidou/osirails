class SendQuoteMethod < ActiveRecord::Base  
  journalize :identifier_method => :name
end
