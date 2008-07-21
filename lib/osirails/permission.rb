module Osirails
  class Permission < ActiveRecord::Base
    belongs_to :has_permission, :polymorphic => true
  end
end
