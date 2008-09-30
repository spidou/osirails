class EstimatesProductReference < ActiveRecord::Base
  belongs_to :estimate, :foreign_key => 'estimate_id'
  belongs_to :product_reference, :foreign_key => 'product_reference_id'
end