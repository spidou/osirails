class CustomerGrade < ActiveRecord::Base
  belongs_to :payment_time_limit
  
  has_search_index :only_attributes => [:name]
end
