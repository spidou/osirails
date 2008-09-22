class Remark < ActiveRecord::Base
  belongs_to :has_remark, :polymorphic => true
  belongs_to :user
end