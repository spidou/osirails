class Person < ActiveRecord::Base
  belongs_to :has_person, :polymorphic => true

  has_attached_file :photo, :path => ":rails_root/assets/:class/photo/:id.:extension"
  
  attr_accessor :should_update, :should_destroy
  
  def should_destroy?
    should_destroy.to_i == 1
  end

  def should_update?
    should_update.to_i == 1
  end
end
