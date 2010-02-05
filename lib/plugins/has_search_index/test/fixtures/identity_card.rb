class IdentityCard < ActiveRecord::Base
  belongs_to :has_identity_card, :polymorphic => true
end
