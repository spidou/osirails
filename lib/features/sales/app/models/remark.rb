class Remark < ActiveRecord::Base
  belongs_to :has_remark, :polymorphic => true
end