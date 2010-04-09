class CustomerGrade < ActiveRecord::Base
  belongs_to :payment_time_limit
end
