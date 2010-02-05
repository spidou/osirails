class PeopleWish < ActiveRecord::Base
  belongs_to :wish
  belongs_to :person, :polymorphic => true
end
