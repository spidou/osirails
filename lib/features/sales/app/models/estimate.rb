class Estimate < ActiveRecord::Base
  belongs_to :step_estimate
  has_many :estimates_product_references
end