module Osirails
  class BusinessObjectPermission < ActiveRecord::Base
    belongs_to :has_permission, :polymorphic => true
  end
end
