class Address < ActiveRecord::Base
  belongs_to :has_address, :polymorphic => true
end