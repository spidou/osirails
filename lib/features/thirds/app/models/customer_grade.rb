## DATABASE STRUCTURE
# A integer "granted_payment_method_id"
# A string  "name"

class CustomerGrade < ActiveRecord::Base
  belongs_to :granted_payment_method
  
  journalize :identifier_method => :name
  
  has_search_index :only_attributes => [ :id, :name ],
                   :identifier      => :name
end
