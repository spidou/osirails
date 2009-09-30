class Number < ActiveRecord::Base
  belongs_to :has_number, :polymorphic => true
  belongs_to :number_type
end
