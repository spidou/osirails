class DocumentType < ActiveRecord::Base
  has_permissions :as_instance
  setup_has_permissions_model
  
  has_and_belongs_to_many :mime_types
  
  # returns name if title is nil or empty
  def title
    (super.nil? or super.empty? ) ? "(#{name})" : super
  end
end
