class PeopleDream < ActiveRecord::Base
  belongs_to :person, :polymorphic => true
  belongs_to :dream
end
