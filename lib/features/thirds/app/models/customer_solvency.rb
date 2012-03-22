## DATABASE STRUCTURE
# A integer "granted_payment_time_id"
# A string  "name"

class CustomerSolvency < ActiveRecord::Base
  belongs_to :granted_payment_time
  
  journalize :identifier_method => :name
  
  has_search_index :only_attributes => [ :id, :name ],
                   :identifier      => :name
end
