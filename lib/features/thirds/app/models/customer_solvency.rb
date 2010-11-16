class CustomerSolvency < ActiveRecord::Base
  belongs_to :payment_method
  
  has_search_index :only_attributes => [ :id, :name ],
                   :identifier      => :name
end
