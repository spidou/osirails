class Checklist < ActiveRecord::Base
  has_many :checklist_options
  has_many :checklist_responses
  belongs_to :step
  
  def options
    checklist_options.empty? ? [ checklist_options.build(:name => "Oui"), checklist_options.build(:name => "Non") ] : checklist_options
  end
  
  def mapped_response(owner)
    raise ArgumentError, "the 'owner' argument must be an instance of an acts_as_step class. #{owner}:#{owner.class}" unless owner.class.respond_to?(:original_step)
    checklist_responses.find_by_has_checklist_response_type_and_has_checklist_response_id(owner.class.name, owner.id)
  end
end
