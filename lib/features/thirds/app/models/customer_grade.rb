class CustomerGrade < ActiveRecord::Base
  belongs_to :payment_time_limit
  
  journalize :identifier_method => :name
  
  has_search_index :only_attributes => [ :id, :name ],
                   :identifier      => :name
end
